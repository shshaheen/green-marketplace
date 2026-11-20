import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../error/exceptions.dart';

/// Non-sensitive local data (e.g. the draft Order Request). Never store tokens,
/// MPINs or personal details here — use [SecureStorageService] for secrets.
class LocalCacheService {
  LocalCacheService([SharedPreferencesAsync? preferences])
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  Future<Object?> readJson(String key) async {
    try {
      final raw = await _preferences.getString(key);
      return raw == null ? null : jsonDecode(raw);
    } on FormatException {
      // Corrupt entry: drop it rather than failing every read.
      await remove(key);
      return null;
    } catch (_) {
      throw StorageException('Could not read "$key"');
    }
  }

  Future<void> writeJson(String key, Object? value) async {
    try {
      await _preferences.setString(key, jsonEncode(value));
    } catch (_) {
      throw StorageException('Could not save "$key"');
    }
  }

  Future<void> remove(String key) async {
    try {
      await _preferences.remove(key);
    } catch (_) {
      throw StorageException('Could not remove "$key"');
    }
  }
}
