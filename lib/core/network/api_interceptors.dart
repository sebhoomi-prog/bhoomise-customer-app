import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';

/// JWT / Bearer — pass a token getter from your session layer when wiring [Dio].
class AuthBearerInterceptor extends Interceptor {
  AuthBearerInterceptor(this._token);

  final String? Function() _token;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final t = _token();
    if (t != null && t.isNotEmpty) {
      options.headers[AppConstants.headerAuthorization] =
          '${AppConstants.bearerPrefix} $t';
    }
    handler.next(options);
  }
}

class ApiLoggerInterceptor extends Interceptor {
  static const bool _releaseApiLogsEnabled = bool.fromEnvironment(
    'ENABLE_API_LOGS',
    defaultValue: false,
  );

  bool get _shouldLog => kDebugMode || _releaseApiLogsEnabled;

  void _log(String message) {
    if (!_shouldLog) return;
    // print() is visible in device/system logs for release builds.
    print(message);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log('\n${'=' * 80}');
    _log('[API][REQ] ${options.method} ${options.baseUrl}${options.path}');
    _log('Query: ${options.queryParameters}');
    _log('Body: ${options.data}');
    _printCurl(options);
    _log('=' * 80);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log('\n${'=' * 80}');
    _log('[API][RES] ${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.uri}');
    _log('Response Headers: ${response.headers.map}');
    _log('Response Data:');
    _prettyPrintJson(response.data);
    _log('=' * 80);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log('\n${'!' * 80}');
    _log('[API][ERR] ${err.response?.statusCode} '
        '${err.requestOptions.method} ${err.requestOptions.uri}');
    _log('Error Message: ${err.message}');
    _log('Error Type: ${err.type}');
    if (err.response?.data != null) {
      _log('Error Response:');
      _prettyPrintJson(err.response?.data);
    }
    _log('!' * 80);
    handler.next(err);
  }

  void _prettyPrintJson(dynamic data) {
    if (!_shouldLog) return;
    try {
      if (data is Map || data is List) {
        const encoder = JsonEncoder.withIndent('  ');
        final prettyJson = encoder.convert(data);
        for (final line in prettyJson.split('\n')) {
          _log(line);
        }
      } else {
        _log('$data');
      }
    } catch (_) {
      _log('$data');
    }
  }

  void _printCurl(RequestOptions options) {
    if (!_shouldLog) return;

    final components = <String>['curl -X ${options.method}'];

    options.headers.forEach((key, value) {
      if (value != null) {
        final escaped = value.toString().replaceAll("'", "\\'");
        components.add("-H '$key: $escaped'");
      }
    });

    if (options.data != null) {
      String body;
      if (options.data is Map || options.data is List) {
        try {
          body = const JsonEncoder().convert(options.data);
        } catch (_) {
          body = options.data.toString();
        }
      } else {
        body = options.data.toString();
      }
      final escaped = body.replaceAll("'", "\\'");
      components.add("-d '$escaped'");
    }

    var url = '${options.baseUrl}${options.path}';
    if (options.queryParameters.isNotEmpty) {
      final queryString = options.queryParameters.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      url = '$url?$queryString';
    }
    components.add("'$url'");

    final curl = components.join(' \\\n  ');
    _log('\n[CURL COMMAND]\n$curl\n');
  }
}
