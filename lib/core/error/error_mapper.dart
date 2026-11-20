import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../network/api_response.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Converts any error from the data layer into an [AppFailure].
/// Call it in repository implementations: `catch (e) { throw mapToFailure(e); }`.
AppFailure mapToFailure(Object error) {
  return switch (error) {
    AppFailure() => error,
    DioException() => _fromDio(error),
    ParseException() => const ServerFailure(
      'We received an unexpected response. Please try again.',
    ),
    StorageException() => const StorageFailure(),
    _ => _unknown(error),
  };
}

AppFailure _fromDio(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const NetworkFailure('The request timed out. Please try again.');
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.cancel:
      return const UnknownFailure('The request was cancelled.');
    case DioExceptionType.badCertificate:
      return const NetworkFailure('Could not establish a secure connection.');
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      break;
  }

  final response = error.response;
  if (response == null) {
    return error.error is AppFailure ? error.error! as AppFailure : const NetworkFailure();
  }
  return fromResponse(response.statusCode ?? 0, response.data);
}

/// Maps an HTTP status and backend error envelope to a failure. Public for tests.
AppFailure fromResponse(int status, Object? body) {
  final apiError = ApiErrorBody.tryParse(body);
  final message = apiError?.message;
  final code = apiError?.code;

  if (code == 'VALIDATION_ERROR' || (status == 400 && (apiError?.details.isNotEmpty ?? false))) {
    return ValidationFailure(
      message ?? 'Please check the highlighted fields.',
      code: code,
      fieldErrors: {
        for (final detail in apiError?.details ?? const <ApiFieldError>[])
          if (detail.fieldName != null) detail.fieldName!: detail.message,
      },
    );
  }

  return switch (status) {
    400 || 413 => ValidationFailure(message ?? 'The request was not valid.', code: code),
    401 => UnauthorizedFailure(message ?? 'Please log in to continue.', code),
    403 => ForbiddenFailure(message ?? 'You do not have access to this.', code: code),
    404 => NotFoundFailure(message ?? 'We could not find what you were looking for.'),
    409 => ConflictFailure(message ?? 'This was changed meanwhile. Please refresh.'),
    429 => RateLimitedFailure(message ?? 'Too many attempts. Please wait and try again.'),
    >= 500 => ServerFailure(message ?? 'Something went wrong on our side. Please try again.', code),
    _ => UnknownFailure(message ?? 'Something went wrong. Please try again.'),
  };
}

AppFailure _unknown(Object error) {
  // Type only: messages from unknown errors may contain request data.
  debugPrint('Unmapped error: ${error.runtimeType}');
  return const UnknownFailure();
}
