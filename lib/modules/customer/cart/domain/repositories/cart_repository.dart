import '../entities/cart_line.dart';

abstract class CartRepository {
  Future<List<CartLine>> getLines();

  Future<void> addOrUpdateLine(CartLine line);

  Future<void> setQuantity(String productId, String variantId, int quantity);

  Future<void> removeLine(String productId, String variantId);

  Future<void> clear();
}
