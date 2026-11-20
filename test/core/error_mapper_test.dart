import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_marketplace/core/error/error_mapper.dart';
import 'package:green_marketplace/core/error/exceptions.dart';
import 'package:green_marketplace/core/error/failures.dart';

Map<String, dynamic> _error(String code, String message, [List<Map<String, String>>? details]) => {
  'success': false,
  'error': {'code': code, 'message': message, 'details': ?details},
};

DioException _dio({
  DioExceptionType type = DioExceptionType.badResponse,
  int? status,
  Object? body,
}) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: type,
    response: status == null
        ? null
        : Response<dynamic>(requestOptions: options, statusCode: status, data: body),
  );
}

void main() {
  group('mapToFailure', () {
    test('network problems become NetworkFailure', () {
      expect(mapToFailure(_dio(type: DioExceptionType.connectionError)), isA<NetworkFailure>());
      expect(mapToFailure(_dio(type: DioExceptionType.receiveTimeout)), isA<NetworkFailure>());
    });

    test('validation errors keep backend field messages', () {
      final failure = mapToFailure(
        _dio(
          status: 400,
          body: _error('VALIDATION_ERROR', 'Request validation failed', [
            {'field': 'body.email', 'message': 'Enter a valid email address'},
          ]),
        ),
      );
      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).fieldErrors, {'email': 'Enter a valid email address'});
      expect(failure.code, 'VALIDATION_ERROR');
    });

    test('status codes map to the right failure with the server message', () {
      expect(
        mapToFailure(
          _dio(status: 401, body: _error('INVALID_CREDENTIALS', 'Invalid email or MPIN')),
        ),
        isA<UnauthorizedFailure>().having((f) => f.message, 'message', 'Invalid email or MPIN'),
      );
      expect(
        mapToFailure(_dio(status: 403, body: _error('FORBIDDEN', 'Account locked'))),
        isA<ForbiddenFailure>(),
      );
      expect(
        mapToFailure(_dio(status: 404, body: _error('NOT_FOUND', 'x'))),
        isA<NotFoundFailure>(),
      );
      expect(
        mapToFailure(_dio(status: 409, body: _error('CONFLICT', 'x'))),
        isA<ConflictFailure>(),
      );
      expect(mapToFailure(_dio(status: 429)), isA<RateLimitedFailure>());
      expect(
        mapToFailure(_dio(status: 503, body: _error('SERVICE_UNAVAILABLE', 'Down'))),
        isA<ServerFailure>(),
      );
      expect(mapToFailure(_dio(status: 413)), isA<ValidationFailure>());
    });

    test('non-JSON error bodies fall back to safe messages', () {
      final failure = mapToFailure(_dio(status: 500, body: '<html>oops</html>'));
      expect(failure, isA<ServerFailure>());
      expect(failure.message, isNot(contains('html')));
    });

    test('passes AppFailures through and maps data-layer exceptions', () {
      const failure = ConflictFailure('Changed');
      expect(mapToFailure(failure), same(failure));
      expect(mapToFailure(const ParseException('bad')), isA<ServerFailure>());
      expect(mapToFailure(const StorageException('bad')), isA<StorageFailure>());
      expect(mapToFailure(StateError('boom')), isA<UnknownFailure>());
    });
  });
}
