import 'dart:async';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/network/network_exceptions.dart';
import 'customer_home_defaults.dart';
import 'models/customer_home_api_model.dart';
import '../domain/customer_home_category.dart';

class CustomerHomeApiDataSource {
  CustomerHomeApiDataSource(this._apiClient);

  final ApiClient _apiClient;
  // Backend currently does not expose `/api/app` on production.
  // Keep remote app-docs disabled by default to avoid startup 404 noise.
  static const bool _enableRemoteAppDocs = bool.fromEnvironment(
    'ENABLE_APP_DOCS_API',
    defaultValue: false,
  );
  bool _appDocsEndpointMissing = !_enableRemoteAppDocs;

  Stream<List<CustomerHomeCategory>> watchCategories({
    Duration interval = const Duration(seconds: 30),
  }) async* {
    yield await fetchCategoriesOnce();
    yield* Stream<void>.periodic(interval)
        .asyncMap((_) => fetchCategoriesOnce());
  }

  Future<List<CustomerHomeCategory>> fetchCategoriesOnce() async {
    if (_appDocsEndpointMissing) {
      return defaultCustomerHomeCategories();
    }
    try {
      final response = await _apiClient.get(
        ApiEndpoints.appDocs,
        queryParameters: const {'key': 'customer_home'},
      );
      final parsed = CustomerHomeApiModel.fromApi(response.data).categories;
      return parsed.isEmpty ? defaultCustomerHomeCategories() : parsed;
    } on NetworkException catch (e) {
      // Backend may not expose this endpoint yet (returns 404 with a message).
      // If so, stop hitting it and fall back to local defaults.
      final msg = e.message.toLowerCase();
      if (msg.contains('route') && msg.contains('could not be found')) {
        _appDocsEndpointMissing = true;
      }
      return defaultCustomerHomeCategories();
    } on Object {
      return defaultCustomerHomeCategories();
    }
  }

  Future<void> saveCategories(List<CustomerHomeCategory> categories) async {
    if (_appDocsEndpointMissing) return;
    await _apiClient.post(
      ApiEndpoints.appDocs,
      data: {
        'key': 'customer_home',
        'categories': categories.map((e) => e.toFirestoreMap()).toList(),
      },
    );
  }

}
