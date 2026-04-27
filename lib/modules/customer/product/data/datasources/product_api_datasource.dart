import '../../../../../core/api/api_client.dart';
import '../../../../../core/api/api_endpoints.dart';
import '../models/product_api_models.dart';
import '../models/product_model.dart';
import 'product_remote_datasource.dart';

class ProductApiDataSource implements ProductRemoteDataSource {
  ProductApiDataSource(this._apiClient);

  final ApiClient _apiClient;

  static const _singleApiPrefixProductsPath = '/api/products';

  @override
  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.products,
        requestTimeout: const Duration(seconds: 6),
      );
      return ProductListResponseModel.fromApi(response.data).items;
    } on Object {
      final legacyResponse = await _apiClient.get(
        _singleApiPrefixProductsPath,
        requestTimeout: const Duration(seconds: 6),
      );
      return ProductListResponseModel.fromApi(legacyResponse.data).items;
    }
  }
}
