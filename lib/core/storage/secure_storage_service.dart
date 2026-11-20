import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../error/exceptions.dart';

/// Which kind of signed-in user a token belongs to. Admin and customer sessions are
/// stored separately and never sent to each other's endpoints.
enum AuthScope { admin, customer }

/// Tokens returned by login, initial MPIN setup and refresh.
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;

  bool get isRefreshExpired => DateTime.now().isAfter(refreshTokenExpiresAt);
}

/// Storage for session tokens. Abstract so the network layer and tests don't depend
/// on the platform plugin.
abstract interface class TokenStore {
  Future<AuthTokens?> read(AuthScope scope);
  Future<void> save(AuthScope scope, AuthTokens tokens);
  Future<void> clear(AuthScope scope);
}

/// Keeps tokens in the iOS Keychain / Android Keystore-backed storage.
/// Values are never logged.
class SecureStorageService implements TokenStore {
  SecureStorageService([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  String _key(AuthScope scope, String field) => 'auth.${scope.name}.$field';

  @override
  Future<AuthTokens?> read(AuthScope scope) async {
    try {
      final access = await _storage.read(key: _key(scope, 'access'));
      final refresh = await _storage.read(key: _key(scope, 'refresh'));
      final expires = await _storage.read(key: _key(scope, 'refreshExpiresAt'));
      if (access == null || refresh == null || expires == null) return null;
      final expiresAt = DateTime.tryParse(expires);
      if (expiresAt == null) return null;
      return AuthTokens(
        accessToken: access,
        refreshToken: refresh,
        refreshTokenExpiresAt: expiresAt,
      );
    } catch (_) {
      throw const StorageException('Could not read the saved session');
    }
  }

  @override
  Future<void> save(AuthScope scope, AuthTokens tokens) async {
    try {
      await _storage.write(key: _key(scope, 'access'), value: tokens.accessToken);
      await _storage.write(key: _key(scope, 'refresh'), value: tokens.refreshToken);
      await _storage.write(
        key: _key(scope, 'refreshExpiresAt'),
        value: tokens.refreshTokenExpiresAt.toUtc().toIso8601String(),
      );
    } catch (_) {
      throw const StorageException('Could not save the session');
    }
  }

  @override
  Future<void> clear(AuthScope scope) async {
    try {
      for (final field in const ['access', 'refresh', 'refreshExpiresAt']) {
        await _storage.delete(key: _key(scope, field));
      }
    } catch (_) {
      throw const StorageException('Could not clear the session');
    }
  }
}
