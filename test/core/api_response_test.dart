import 'package:flutter_test/flutter_test.dart';
import 'package:green_marketplace/core/error/exceptions.dart';
import 'package:green_marketplace/core/network/api_response.dart';

void main() {
  group('ApiResponse', () {
    test('parses data and pagination meta', () {
      final response = ApiResponse.fromJson({
        'success': true,
        'data': [1, 2],
        'meta': {'page': 1, 'limit': 2, 'total': 5, 'totalPages': 3},
      }, (data) => (data! as List).cast<int>());
      expect(response.data, [1, 2]);
      expect(response.meta!.total, 5);
      expect(response.meta!.hasNextPage, isTrue);
    });

    test('meta is optional', () {
      final response = ApiResponse.fromJson({'success': true, 'data': null}, (data) => data);
      expect(response.meta, isNull);
    });

    test('rejects non-success envelopes and non-objects', () {
      expect(
        () => ApiResponse.fromJson({'success': false}, (d) => d),
        throwsA(isA<ParseException>()),
      );
      expect(() => ApiResponse.fromJson('oops', (d) => d), throwsA(isA<ParseException>()));
    });
  });

  group('ApiErrorBody', () {
    test('parses code, message and field details, stripping request prefixes', () {
      final error = ApiErrorBody.tryParse({
        'success': false,
        'error': {
          'code': 'VALIDATION_ERROR',
          'message': 'Request validation failed',
          'details': [
            {'field': 'body.customerDetails.phone', 'message': 'Enter a valid number'},
            {'message': 'General problem'},
          ],
        },
      })!;
      expect(error.code, 'VALIDATION_ERROR');
      expect(error.details.first.fieldName, 'customerDetails.phone');
      expect(error.details.last.fieldName, isNull);
    });

    test('returns null for anything else', () {
      expect(ApiErrorBody.tryParse('<html>'), isNull);
      expect(ApiErrorBody.tryParse({'success': false}), isNull);
    });
  });

  group('JsonRead', () {
    test('typed reads and clear errors', () {
      final json = <String, dynamic>{
        'name': 'Jade',
        'count': 3,
        'whole': 4.0,
        'date': '2026-12-05T10:00:00.000Z',
        'tags': ['a', 'b'],
      };
      expect(json.readString('name'), 'Jade');
      expect(json.readInt('count'), 3);
      expect(json.readInt('whole'), 4);
      expect(json.readDate('date').toUtc(), DateTime.utc(2026, 12, 5, 10));
      expect(json.readStringList('tags'), ['a', 'b']);
      expect(json.readStringOrNull('missing'), isNull);
      expect(json.readList('missing'), isEmpty);
      expect(() => json.readInt('name'), throwsA(isA<ParseException>()));
      expect(() => json.readString('count'), throwsA(isA<ParseException>()));
    });
  });
}
