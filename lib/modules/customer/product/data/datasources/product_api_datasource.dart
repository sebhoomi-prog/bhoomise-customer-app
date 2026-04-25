import '../../../../../core/api/api_client.dart';
import '../../../../../core/api/api_endpoints.dart';
import '../models/product_api_models.dart';
import '../models/product_model.dart';
import 'product_remote_datasource.dart';

class ProductApiDataSource implements ProductRemoteDataSource {
  ProductApiDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ProductModel>> fetchProducts() async {
    final response = await _apiClient.get(ApiEndpoints.products);
    return ProductListResponseModel.fromApi(response.data).items;
  }
}
