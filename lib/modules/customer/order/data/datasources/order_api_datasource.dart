import 'dart:async';

import '../../../../../core/api/api_client.dart';
import '../../../../../core/api/api_endpoints.dart';
import '../../../data/models/api_models_index.dart';

class OrderApiDataSource {
  OrderApiDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<OrderApiModel>> fetchOrders() async {
    final response = await _apiClient.get(ApiEndpoints.orders);
    return OrderListResponseModel.fromApi(response.data).items;
  }

  Future<OrderApiModel> createOrder(CreateOrderRequestModel request) async {
    final response = await _apiClient.post(
      ApiEndpoints.orders,
      data: request.toJson(),
    );
    final orders = OrderListResponseModel.fromApi(response.data).items;
    if (orders.isNotEmpty) return orders.first;
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final raw = data['data'];
      if (raw is Map<String, dynamic>) {
        return OrderApiModel.fromJson(raw);
      }
      return OrderApiModel.fromJson(data);
    }
    throw const FormatException('Invalid create order response payload.');
  }
}
