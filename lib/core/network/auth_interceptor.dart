import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';

/// Decides which session (if any) a request needs, from its path.
///
/// - `/admin/*` and `/auth/admin/me` → admin token
/// - `/order-requests/*` and `/auth/customer/me` → customer token
/// - catalogue and all other auth endpoints (login, OTP, refresh…) → no token
///
/// A request can override this with `Options(extra: {AuthInterceptor.scopeKey: …})`.
AuthScope? scopeForPath(String path) {
  if (path.startsWith('/admin/') || path == ApiEndpoints.adminMe) return AuthScope.admin;
  if (path.startsWith(ApiEndpoints.orderRequests) || path == ApiEndpoints.customerMe) {
    return AuthScope.customer;
  }
  return null;
}

/// Attaches the right Bearer token, and on a 401 refreshes that session once and
/// retries. When refreshing fails, the session is cleared and [onSessionExpired] fires
/// so the app can return to the login screen.
///
/// Queued, so concurrent 401s refresh only once.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this._tokenStore,
    required this._refreshClient,
    required this._onSessionExpired,
  });

  /// `extra` key to force a scope (`AuthScope`) or `false` to send no token.
  static const String scopeKey = 'authScope';
  static const String _retriedKey = 'authRetried';
  static const String _sentTokenKey = 'authSentToken';

  final TokenStore _tokenStore;

  /// A Dio without this interceptor, used to refresh and to replay the request.
  /// Replaying through the main Dio could deadlock this queued interceptor.
  final Dio _refreshClient;
  final void Function(AuthScope scope) _onSessionExpired;

  AuthScope? _scopeOf(RequestOptions options) {
    final override = options.extra[scopeKey];
    if (override is AuthScope) return override;
    if (override == false) return null;
    return scopeForPath(options.path);
  }

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final scope = _scopeOf(options);
    if (scope != null) {
      final tokens = await _tokenStore.read(scope);
      if (tokens != null) {
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
        options.extra[_sentTokenKey] = tokens.accessToken;
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final scope = _scopeOf(options);
    final isUnauthorized = err.response?.statusCode == 401;

    if (!isUnauthorized || scope == null || options.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    final current = await _tokenStore.read(scope);
    if (current == null) return handler.next(err);

    // Another queued request may already have refreshed: only refresh if the token
    // we sent is still the stored one.
    var tokens = current;
    if (options.extra[_sentTokenKey] == current.accessToken) {
      final refreshed = await _refresh(scope, current);
      if (refreshed == null) {
        await _tokenStore.clear(scope);
        _onSessionExpired(scope);
        return handler.next(err);
      }
      tokens = refreshed;
    }

    try {
      final retryOptions = options
        ..headers['Authorization'] = 'Bearer ${tokens.accessToken}'
        ..extra[_retriedKey] = true
        ..extra[_sentTokenKey] = tokens.accessToken;
      final response = await _refreshClient.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<AuthTokens?> _refresh(AuthScope scope, AuthTokens current) async {
    if (current.isRefreshExpired) return null;
    final path = scope == AuthScope.admin
        ? ApiEndpoints.adminRefresh
        : ApiEndpoints.customerRefresh;
    try {
      final response = await _refreshClient.post<Map<String, dynamic>>(
        path,
        data: {'refreshToken': current.refreshToken},
      );
      final data = response.data?['data'];
      if (data is! Map) return null;
      final access = data['accessToken'];
      final refresh = data['refreshToken'];
      final expiresAt = DateTime.tryParse('${data['refreshTokenExpiresAt']}');
      if (access is! String || refresh is! String || expiresAt == null) return null;

      final tokens = AuthTokens(
        accessToken: access,
        refreshToken: refresh,
        refreshTokenExpiresAt: expiresAt,
      );
      await _tokenStore.save(scope, tokens);
      return tokens;
    } on DioException {
      return null;
    }
  }
}
