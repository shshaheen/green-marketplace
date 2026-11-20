import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_marketplace/core/network/auth_interceptor.dart';
import 'package:green_marketplace/core/storage/secure_storage_service.dart';

class _MemoryTokenStore implements TokenStore {
  final Map<AuthScope, AuthTokens> tokens = {};

  @override
  Future<AuthTokens?> read(AuthScope scope) async => tokens[scope];

  @override
  Future<void> save(AuthScope scope, AuthTokens value) async => tokens[scope] = value;

  @override
  Future<void> clear(AuthScope scope) async => tokens.remove(scope);
}

typedef _Handler = (int, Object?) Function(RequestOptions options);

/// Answers requests with [handler] and records them.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final _Handler handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final (status, body) = handler(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

AuthTokens _tokens(String access, {String refresh = 'refresh-1', int days = 7}) => AuthTokens(
  accessToken: access,
  refreshToken: refresh,
  refreshTokenExpiresAt: DateTime.now().add(Duration(days: days)),
);

void main() {
  late _MemoryTokenStore store;
  late List<AuthScope> expired;

  /// Builds a client whose API returns 401 unless the token matches [validToken].
  (Dio, _FakeAdapter, _FakeAdapter) build({
    String validToken = 'access-1',
    (int, Object?) Function()? refreshResponse,
  }) {
    final api = _FakeAdapter((options) {
      final auth = options.headers['Authorization'];
      final needsAuth = scopeForPath(options.path) != null;
      if (needsAuth && auth != 'Bearer $validToken') {
        return (
          401,
          {
            'success': false,
            'error': {'code': 'UNAUTHORIZED', 'message': 'no'},
          },
        );
      }
      return (
        200,
        {
          'success': true,
          'data': {'auth': auth},
        },
      );
    });
    final refresh = _FakeAdapter(
      (options) => options.path.endsWith('/refresh')
          ? (refreshResponse?.call() ?? (401, null))
          : api.handler(options),
    );
    final refreshClient = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
      ..httpClientAdapter = refresh;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
      ..httpClientAdapter = api
      ..interceptors.add(
        AuthInterceptor(
          tokenStore: store,
          refreshClient: refreshClient,
          onSessionExpired: expired.add,
        ),
      );
    return (dio, api, refresh);
  }

  setUp(() {
    store = _MemoryTokenStore();
    expired = [];
  });

  test('scopeForPath picks the session from the path', () {
    expect(scopeForPath('/admin/plants'), AuthScope.admin);
    expect(scopeForPath('/auth/admin/me'), AuthScope.admin);
    expect(scopeForPath('/order-requests/mine'), AuthScope.customer);
    expect(scopeForPath('/auth/customer/me'), AuthScope.customer);
    expect(scopeForPath('/plants'), isNull);
    expect(scopeForPath('/auth/admin/login'), isNull);
    expect(scopeForPath('/auth/customer/refresh'), isNull);
  });

  test('sends each token only to its own endpoints', () async {
    store.tokens[AuthScope.admin] = _tokens('admin-token');
    store.tokens[AuthScope.customer] = _tokens('customer-token');
    final (dio, api, _) = build(validToken: 'admin-token');

    await dio.get<dynamic>('/admin/plants');
    await dio.get<dynamic>('/plants');
    await dio.post<dynamic>('/auth/admin/login');
    await dio
        .get<dynamic>('/order-requests/mine')
        .catchError((_) => Response<dynamic>(requestOptions: RequestOptions()));

    final headers = api.requests.map((r) => r.headers['Authorization']).toList();
    expect(headers[0], 'Bearer admin-token');
    expect(headers[1], isNull);
    expect(headers[2], isNull);
    expect(headers[3], 'Bearer customer-token');
  });

  test('on 401 refreshes once, saves the new tokens and retries', () async {
    store.tokens[AuthScope.admin] = _tokens('stale');
    final (dio, _, refresh) = build(
      validToken: 'fresh',
      refreshResponse: () => (
        200,
        {
          'success': true,
          'data': {
            'accessToken': 'fresh',
            'refreshToken': 'refresh-2',
            'refreshTokenExpiresAt': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          },
        },
      ),
    );

    final response = await dio.get<Map<String, dynamic>>('/admin/plants');

    expect(response.data!['data'], {'auth': 'Bearer fresh'});
    expect(store.tokens[AuthScope.admin]!.refreshToken, 'refresh-2');
    expect(refresh.requests.where((r) => r.path.endsWith('/refresh')), hasLength(1));
    expect(expired, isEmpty);
  });

  test('when refresh fails, clears the session and reports it expired', () async {
    store.tokens[AuthScope.customer] = _tokens('stale');
    final (dio, _, _) = build(validToken: 'never');

    await expectLater(
      dio.get<dynamic>('/order-requests/mine'),
      throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 401)),
    );
    expect(store.tokens[AuthScope.customer], isNull);
    expect(expired, [AuthScope.customer]);
  });

  test('an expired refresh token is not sent', () async {
    store.tokens[AuthScope.admin] = _tokens('stale', days: -1);
    final (dio, _, refresh) = build(validToken: 'never');

    await expectLater(dio.get<dynamic>('/admin/plants'), throwsA(isA<DioException>()));
    expect(refresh.requests.where((r) => r.path.endsWith('/refresh')), isEmpty);
    expect(expired, [AuthScope.admin]);
  });

  test('401 from a public endpoint does not trigger a refresh', () async {
    store.tokens[AuthScope.admin] = _tokens('admin-token');
    final (dio, _, refresh) = build();
    final adapter = dio.httpClientAdapter as _FakeAdapter;
    dio.httpClientAdapter = _FakeAdapter((options) {
      adapter.requests.add(options);
      return (
        401,
        {
          'success': false,
          'error': {'code': 'INVALID_CREDENTIALS', 'message': 'x'},
        },
      );
    });

    await expectLater(dio.post<dynamic>('/auth/admin/login'), throwsA(isA<DioException>()));
    expect(refresh.requests, isEmpty);
    expect(store.tokens[AuthScope.admin], isNotNull);
    expect(expired, isEmpty);
  });
}
