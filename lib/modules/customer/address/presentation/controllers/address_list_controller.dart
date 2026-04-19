import 'dart:async';

import 'package:get/get.dart';

import '../../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/delivery_address.dart';
import '../../domain/usecases/delete_delivery_address.dart';
import '../../domain/usecases/set_default_delivery_address.dart';
import '../../domain/usecases/watch_delivery_addresses.dart';

class AddressListController extends GetxController {
  AddressListController(
    this._watchAddresses,
    this._deleteAddress,
    this._setDefault,
  );

  final WatchDeliveryAddresses _watchAddresses;
  final DeleteDeliveryAddress _deleteAddress;
  final SetDefaultDeliveryAddress _setDefault;

  final RxList<DeliveryAddress> addresses = <DeliveryAddress>[].obs;
  final RxBool loading = true.obs;
  /// Selected row for checkout / delivery confirmation (Figma radio).
  final RxnString selectedDeliveryId = RxnString();

  StreamSubscription<List<DeliveryAddress>>? _sub;

  void _syncSelected(List<DeliveryAddress> list) {
    if (list.isEmpty) {
      selectedDeliveryId.value = null;
      return;
    }
    final cur = selectedDeliveryId.value;
    if (cur != null && list.any((a) => a.id == cur)) return;
    selectedDeliveryId.value = list
        .firstWhere(
          (a) => a.isDefault,
          orElse: () => list.first,
        )
        .id;
  }

  void selectAddress(DeliveryAddress a) {
    selectedDeliveryId.value = a.id;
  }

  @override
  void onInit() {
    super.onInit();
    final uid = Get.find<AuthController>().currentUser.value?.uid;
    if (uid == null) {
      loading.value = false;
      return;
    }
    _sub = _watchAddresses(uid).listen((list) {
      addresses.assignAll(list);
      _syncSelected(list);
      loading.value = false;
    });
  }

  Future<void> delete(DeliveryAddress a) async {
    final uid = Get.find<AuthController>().currentUser.value?.uid;
    if (uid == null) return;
    await _deleteAddress(uid, a.id);
  }

  Future<void> setDefault(DeliveryAddress a) async {
    final uid = Get.find<AuthController>().currentUser.value?.uid;
    if (uid == null) return;
    await _setDefault(uid, a.id);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
