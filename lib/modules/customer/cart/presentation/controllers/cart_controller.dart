import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/cart_line.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/add_to_cart.dart';
import '../../domain/usecases/change_cart_quantity.dart';
import '../../domain/usecases/remove_from_cart.dart';

/// Cart backed by Hive; applies **optimistic UI** + [cartVersion] bumps so every qty
/// change rebuilds listeners (Blinkit-style — badge/steppers track units, not SKU count).
class CartController extends GetxController with WidgetsBindingObserver {
  CartController(
    this._repository,
    this._addToCart,
    this._removeFromCart,
    this._changeQuantity,
  );

  final CartRepository _repository;
  final AddToCart _addToCart;
  final RemoveFromCart _removeFromCart;
  final ChangeCartQuantity _changeQuantity;

  final RxList<CartLine> lines = <CartLine>[].obs;

  /// Increment whenever lines change so [Obx] can depend on `.value` (qty edits
  /// without line-count change still notify).
  final RxInt cartVersion = 0.obs;

  /// Tracks prior auth so we only wipe the cart on sign-out, not on cold-start guest.
  bool _hadSignedInUser = false;

  int get totalMinor =>
      lines.fold(0, (sum, line) => sum + line.lineTotalMinor);

  /// Sum of line quantities (units), for badges / "N items".
  int get totalItemQuantity =>
      lines.fold(0, (sum, line) => sum + line.quantity);

  CartLine? lineForVariant(String productId, String variantId) {
    for (final l in lines) {
      if (l.productId == productId && l.variantId == variantId) return l;
    }
    return null;
  }

  void _bump() => cartVersion.value++;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    final auth = Get.find<AuthController>();
    _hadSignedInUser = auth.currentUser.value != null;
    ever(auth.currentUser, (user) async {
      if (_hadSignedInUser && user == null) {
        await _repository.clear();
        await refreshCart();
      }
      _hadSignedInUser = user != null;
    });
    refreshCart();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshCart();
    }
  }

  Future<void> refreshCart() async {
    lines.assignAll(await _repository.getLines());
    _bump();
  }

  /// Optimistic merge → persist → reconcile (instant UI like quick-commerce apps).
  Future<void> addLine(CartLine incoming) async {
    final i = lines.indexWhere(
      (l) =>
          l.productId == incoming.productId &&
          l.variantId == incoming.variantId,
    );
    if (i >= 0) {
      lines[i] = lines[i].copyWith(
        quantity: lines[i].quantity + incoming.quantity,
        imageUrl: incoming.imageUrl ?? lines[i].imageUrl,
        lineTag: incoming.lineTag ?? lines[i].lineTag,
        variantGrams: incoming.variantGrams ?? lines[i].variantGrams,
      );
    } else {
      lines.add(incoming);
    }
    _bump();
    try {
      await _addToCart(incoming);
    } finally {
      await refreshCart();
    }
  }

  Future<void> increment(CartLine line) async {
    final i = lines.indexWhere(
      (l) =>
          l.productId == line.productId && l.variantId == line.variantId,
    );
    if (i < 0) return;
    lines[i] = lines[i].copyWith(quantity: lines[i].quantity + 1);
    _bump();
    try {
      await _changeQuantity(line.productId, line.variantId, lines[i].quantity);
    } finally {
      await refreshCart();
    }
  }

  Future<void> decrement(CartLine line) async {
    final i = lines.indexWhere(
      (l) =>
          l.productId == line.productId && l.variantId == line.variantId,
    );
    if (i < 0) return;
    final next = lines[i].quantity - 1;
    if (next <= 0) {
      lines.removeAt(i);
    } else {
      lines[i] = lines[i].copyWith(quantity: next);
    }
    _bump();
    try {
      await _changeQuantity(line.productId, line.variantId, next);
    } finally {
      await refreshCart();
    }
  }

  Future<void> remove(CartLine line) async {
    lines.removeWhere(
      (l) =>
          l.productId == line.productId && l.variantId == line.variantId,
    );
    _bump();
    try {
      await _removeFromCart(line.productId, line.variantId);
    } finally {
      await refreshCart();
    }
  }
}
