import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_constants.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

/// Builds the app's HTTP clients.
abstract final class DioClient {
  /// Plain client with base options and safe logging, but no auth.
  static Dio createBase(String baseUrl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        contentType: Headers.jsonContentType,
        headers: const {'Accept': 'application/json'},
      ),
    );
    if (kDebugMode) dio.interceptors.add(_SafeLogInterceptor());
    return dio;
  }

  /// Main API client: attaches session tokens and refreshes them on 401.
  static Dio createApi({
    required String baseUrl,
    required TokenStore tokenStore,
    required void Function(AuthScope scope) onSessionExpired,
  }) {
    final dio = createBase(baseUrl);
    dio.interceptors.insert(
      0,
      AuthInterceptor(
        tokenStore: tokenStore,
        refreshClient: createBase(baseUrl),
        onSessionExpired: onSessionExpired,
      ),
    );
    return dio;
  }
}

/// Logs method, path and status only — never headers, bodies or query values,
/// which can contain tokens, MPINs, OTPs or personal details.
class _SafeLogInterceptor extends Interceptor {
  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    debugPrint(
      '[api] ${response.requestOptions.method} ${response.requestOptions.path} '
      '→ ${response.statusCode}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '[api] ${err.requestOptions.method} ${err.requestOptions.path} '
      '→ ${err.response?.statusCode ?? err.type.name}',
    );
    handler.next(err);
  }
}
