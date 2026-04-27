import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import 'product_remote_datasource.dart';

/// Tries API first and falls back to local mock catalog on transient failures.
class ProductResilientDataSource implements ProductRemoteDataSource {
  ProductResilientDataSource({
    required ProductRemoteDataSource primary,
    required ProductRemoteDataSource fallback,
    this.primaryTimeout = const Duration(seconds: 6),
  }) : _primary = primary,
       _fallback = fallback;

  final ProductRemoteDataSource _primary;
  final ProductRemoteDataSource _fallback;
  final Duration primaryTimeout;

  @override
  Future<List<ProductModel>> fetchProducts() async {
    try {
      final remote = await _primary.fetchProducts().timeout(primaryTimeout);
      if (remote.isNotEmpty) return remote;
      debugPrint('[ProductResilientDataSource] primary returned empty list');
    } on TimeoutException catch (e) {
      debugPrint('[ProductResilientDataSource] primary timed out: $e');
    } catch (e) {
      debugPrint('[ProductResilientDataSource] primary failed: $e');
    }
    return _fallback.fetchProducts();
  }
}
