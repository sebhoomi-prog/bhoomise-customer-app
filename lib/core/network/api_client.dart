import 'dart:async';

import 'package:dio/dio.dart';

import 'network_exceptions.dart';

/// Thin wrapper over [Dio]. Used only from `*_api_datasource.dart` files.
class ApiClient {
  ApiClient({Dio? dio, String? baseUrl})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? '',
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
              ),
            );

  final Dio _dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? query,
    Duration? requestTimeout,
  }) async {
    final qp = queryParameters ?? query;
    try {
      return await _sendWithOptionalTimeout(
        (cancelToken) => _dio.get<dynamic>(
          path,
          queryParameters: qp,
          cancelToken: cancelToken,
        ),
        requestTimeout,
      );
    } on DioException catch (e) {
      if (_isRetriableConnectError(e)) {
        try {
          await Future<void>.delayed(const Duration(milliseconds: 400));
          return await _sendWithOptionalTimeout(
            (cancelToken) => _dio.get<dynamic>(
              path,
              queryParameters: qp,
              cancelToken: cancelToken,
            ),
            requestTimeout,
          );
        } on DioException catch (_) {
          // fall through to normalized error below
        }
      }
      if (e.error is NetworkException) rethrow;
      throw NetworkException(
        _messageFromDio(e),
        code: e.type.name,
      );
    }
  }

  static const int _maxPostRedirectHops = 5;

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Duration? requestTimeout,
  }) async {
    // `dart:io` does not follow redirects for requests with a body, so 3xx
    // are surfaced to Dio. Resolve `Location` (relative or absolute) and replay POST.
    var url = path;
    DioException? lastE;
    for (var hop = 0; hop < _maxPostRedirectHops; hop++) {
      try {
        return await _sendWithOptionalTimeout(
          (cancelToken) => _dio.post<dynamic>(
            url,
            data: data,
            queryParameters: queryParameters,
            cancelToken: cancelToken,
          ),
          requestTimeout,
        );
      } on DioException catch (e) {
        lastE = e;
        final next = _postRedirectUrl(e);
        if (next != null && next != url) {
          url = next;
          continue;
        }
        final fallbackPath = _legacyApiPathFallback(path, e);
        if (fallbackPath != null) {
          try {
            return await _sendWithOptionalTimeout(
              (cancelToken) => _dio.post<dynamic>(
                fallbackPath,
                data: data,
                queryParameters: queryParameters,
                cancelToken: cancelToken,
              ),
              requestTimeout,
            );
          } on DioException catch (_) {
            // Fall through to connect retry and normalized error.
          }
        }
        if (_isRetriableConnectError(e)) {
          try {
            await Future<void>.delayed(const Duration(milliseconds: 400));
            return await _sendWithOptionalTimeout(
              (cancelToken) => _dio.post<dynamic>(
                path,
                data: data,
                queryParameters: queryParameters,
                cancelToken: cancelToken,
              ),
              requestTimeout,
            );
          } on DioException catch (_) {
            // fall through
          }
        }
        if (e.error is NetworkException) rethrow;
        throw NetworkException(
          _messageFromDio(e),
          code: e.type.name,
        );
      }
    }
    final e = lastE;
    if (e != null) {
      final err = e.error;
      if (err is NetworkException) throw err;
      throw NetworkException(
        _messageFromDio(e),
        code: e.type.name,
      );
    }
    throw NetworkException('Request failed', code: 'post_redirect');
  }

  static String _messageFromDio(DioException e) {
    final status = e.response?.statusCode;
    if (status != null && status >= 300 && status < 400) {
      return 'Server redirect error ($status). Please retry.';
    }
    final data = e.response?.data;
    if (data is Map) {
      final m = data['message'] ?? data['error'] ?? data['detail'];
      if (m != null) return m.toString();
    }
    return e.message ?? 'Request failed';
  }

  static bool _isRetriableConnectError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError;
  }

  static bool _isRedirectStatus(int? code) {
    return code == 301 ||
        code == 302 ||
        code == 303 ||
        code == 307 ||
        code == 308;
  }

  /// Next URL for a 3xx response, or null. Uses [Uri.resolve] so relative
  /// `Location` values (e.g. trailing slash) work. Returns a string Dio accepts
  /// as path (including `https://...` which bypasses [BaseOptions.baseUrl]).
  String? _postRedirectUrl(DioException e) {
    if (!_isRedirectStatus(e.response?.statusCode)) return null;
    final loc = e.response?.headers.value('location')?.trim();
    if (loc == null || loc.isEmpty) return null;
    final requestUri = e.requestOptions.uri;
    final resolved = requestUri.resolve(loc);
    final next = resolved.toString();
    if (next == requestUri.toString()) return null;
    return next;
  }

  static String? _legacyApiPathFallback(String path, DioException e) {
    if (!path.startsWith('/api/')) return null;
    if (path.startsWith('/api/api/')) return null;
    final code = e.response?.statusCode;
    // Some deployed environments still expose endpoints at /api/api/*
    // and return redirect/not-found for /api/*.
    if (code == 301 ||
        code == 302 ||
        code == 303 ||
        code == 307 ||
        code == 308 ||
        code == 404) {
      return '/api$path';
    }
    return null;
  }

  Future<Response<dynamic>> _sendWithOptionalTimeout(
    Future<Response<dynamic>> Function(CancelToken token) sender,
    Duration? timeout,
  ) async {
    if (timeout == null) {
      return sender(CancelToken());
    }

    final cancelToken = CancelToken();
    Timer? timer;
    try {
      timer = Timer(timeout, () {
        if (!cancelToken.isCancelled) {
          cancelToken.cancel('client timeout');
        }
      });
      return await sender(cancelToken);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e) && cancelToken.isCancelled) {
        throw DioException(
          requestOptions: e.requestOptions,
          type: DioExceptionType.connectionTimeout,
          message:
              'The request connection took longer than ${timeout.toString()} and it was aborted.',
          error: e.error,
        );
      }
      rethrow;
    } finally {
      timer?.cancel();
    }
  }
}
