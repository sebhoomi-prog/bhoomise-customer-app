import '../../modules/customer/cart/domain/entities/cart_line.dart';

class CartBlocState {
  const CartBlocState({
    this.lines = const <CartLine>[],
    this.loading = false,
    this.errorMessage,
  });

  final List<CartLine> lines;
  final bool loading;
  final String? errorMessage;

  int get totalMinor =>
      lines.fold(0, (sum, line) => sum + line.lineTotalMinor);

  int get totalItemQuantity =>
      lines.fold(0, (sum, line) => sum + line.quantity);

  CartLine? lineForVariant(String productId, String variantId) {
    for (final l in lines) {
      if (l.productId == productId && l.variantId == variantId) return l;
    }
    return null;
  }

  CartBlocState copyWith({
    List<CartLine>? lines,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CartBlocState(
      lines: lines ?? this.lines,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
