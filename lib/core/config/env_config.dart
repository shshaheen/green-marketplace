/// Build-time configuration, supplied per flavor with
/// `flutter run --dart-define-from-file=config/dev.json`.
///
/// Never put secrets here: everything compiled into the app can be extracted.
abstract final class EnvConfig {
  /// `dev` or `prod`.
  static const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  /// Server origin without a trailing slash, e.g. `https://api.example.com`.
  static const String apiOrigin = String.fromEnvironment('API_ORIGIN');

  /// Base URL for every API call.
  static String get apiBaseUrl => '$apiOrigin/api/v1';

  static bool get isProduction => flavor == 'prod';

  /// Fails fast at startup when the build was made without a config file.
  static void ensureConfigured() {
    if (apiOrigin.isEmpty) {
      throw StateError(
        'API_ORIGIN is not set. Run with --dart-define-from-file=config/<flavor>.json',
      );
    }
  }
}
