/// Low-level exceptions thrown inside the data layer. Repositories convert them
/// (and Dio errors) into [AppFailure]s with `mapToFailure` before they reach the UI.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The server answered, but not in the shape we expected.
final class ParseException extends AppException {
  const ParseException(super.message);
}

/// Reading or writing device storage failed.
final class StorageException extends AppException {
  const StorageException(super.message);
}
