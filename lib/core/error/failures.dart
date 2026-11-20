/// Every error the UI can receive. Repositories throw these, notifiers expose them
/// through `AsyncValue`, and screens switch over them exhaustively.
sealed class AppFailure implements Exception {
  const AppFailure(this.message, {this.code});

  /// A message that is safe to show to the user.
  final String message;

  /// Backend error code (e.g. `VALIDATION_ERROR`), when there is one.
  final String? code;

  /// Whether retrying the same action may succeed.
  bool get isRetryable => false;

  @override
  String toString() => '$runtimeType(${code ?? '-'}): $message';
}

/// No connection, DNS failure or timeout.
final class NetworkFailure extends AppFailure {
  const NetworkFailure([
    super.message = 'No internet connection. Check your network and try again.',
  ]);

  @override
  bool get isRetryable => true;
}

/// Invalid input. [fieldErrors] maps form field names (e.g. `email`, `items.0.quantity`)
/// to messages so forms can show them next to the right field.
final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, {super.code, this.fieldErrors = const {}});

  final Map<String, String> fieldErrors;
}

/// Wrong credentials, or the session expired and could not be refreshed.
final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure([super.message = 'Please log in to continue.', String? code])
    : super(code: code);
}

/// Logged in but not allowed, e.g. an account temporarily locked after failed attempts.
final class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure(super.message, {super.code});
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = 'We could not find what you were looking for.'])
    : super(code: 'NOT_FOUND');
}

/// The action conflicts with the current state, e.g. a status that changed meanwhile.
final class ConflictFailure extends AppFailure {
  const ConflictFailure(super.message) : super(code: 'CONFLICT');
}

final class RateLimitedFailure extends AppFailure {
  const RateLimitedFailure([super.message = 'Too many attempts. Please wait and try again.'])
    : super(code: 'TOO_MANY_REQUESTS');
}

/// 5xx, or the server is temporarily unable to handle the request.
final class ServerFailure extends AppFailure {
  const ServerFailure([
    super.message = 'Something went wrong on our side. Please try again.',
    String? code,
  ]) : super(code: code);

  @override
  bool get isRetryable => true;
}

/// Device storage could not be read or written.
final class StorageFailure extends AppFailure {
  const StorageFailure([super.message = 'Could not access device storage.']);
}

/// Anything we could not classify. Logged with details, shown generically.
final class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'Something went wrong. Please try again.']);

  @override
  bool get isRetryable => true;
}
