import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../constants/app_constants.dart';

/// Single place that constructs [Dio] for [ApiClient]. Add [AuthBearerInterceptor] via
/// [extraInterceptors] when JWT session exists.
class DioFactory {
  DioFactory._();

  static Dio create({
    required String baseUrl,
    List<Interceptor> extraInterceptors = const [],
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 45),
        headers: <String, dynamic>{
          Headers.contentTypeHeader: Headers.jsonContentType,
          AppConstants.headerAccept: AppConstants.valueApplicationJson,
        },
      ),
    );
    final adapter = dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 45);
        // Use the platform default resolver and connection behavior (no custom
        // socket order). Custom IPv4-first logic can break real devices and some
        // emulators when the OS expects dual-stack / different address order.
        return client;
      };
    }
    dio.interceptors.addAll(extraInterceptors);
    return dio;
  }
}
