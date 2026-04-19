import '../models/product_model.dart';

/// Contract for product listing. Implementations: asset/mock sources, future
/// HTTP implementation using [ApiClient] only in that file (see `BackendConfig`).
abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> fetchProducts();
}
