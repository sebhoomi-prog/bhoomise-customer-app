import '../repositories/cart_repository.dart';

class ChangeCartQuantity {
  ChangeCartQuantity(this._repository);

  final CartRepository _repository;

  Future<void> call(String productId, String variantId, int quantity) =>
      _repository.setQuantity(productId, variantId, quantity);
}
