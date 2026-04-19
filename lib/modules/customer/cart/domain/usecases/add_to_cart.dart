import '../entities/cart_line.dart';
import '../repositories/cart_repository.dart';

class AddToCart {
  AddToCart(this._repository);

  final CartRepository _repository;

  Future<void> call(CartLine line) => _repository.addOrUpdateLine(line);
}
