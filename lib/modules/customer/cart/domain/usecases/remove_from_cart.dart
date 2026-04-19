import '../repositories/cart_repository.dart';

class RemoveFromCart {
  RemoveFromCart(this._repository);

  final CartRepository _repository;

  Future<void> call(String productId, String variantId) =>
      _repository.removeLine(productId, variantId);
}
