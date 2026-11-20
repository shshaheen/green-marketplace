import 'package:flutter_test/flutter_test.dart';
import 'package:green_marketplace/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('required trims whitespace', () {
      expect(Validators.required('  ', field: 'Name'), 'Name is required');
      expect(Validators.required('Asha'), isNull);
    });

    test('email and optionalEmail', () {
      expect(Validators.email('asha@example.com'), isNull);
      expect(Validators.email('asha@'), 'Enter a valid email address');
      expect(Validators.email(''), 'Email is required');
      expect(Validators.optionalEmail(''), isNull);
      expect(Validators.optionalEmail('bad'), 'Enter a valid email address');
    });

    test('mobile accepts Indian formats and normalizes them', () {
      for (final value in ['9876543210', '+91 98765 43210', '098765-43210', '91 9876543210']) {
        expect(Validators.mobile(value), isNull, reason: value);
      }
      expect(Validators.normalizeMobile('+91 98765-43210'), '9876543210');
      expect(Validators.mobile('5876543210'), 'Enter a valid 10-digit mobile number');
      expect(Validators.mobile('98765'), 'Enter a valid 10-digit mobile number');
    });

    test('pincode is 6 digits, not starting with 0', () {
      expect(Validators.pincode('500001'), isNull);
      expect(Validators.pincode('050001'), isNotNull);
      expect(Validators.pincode('5000'), isNotNull);
    });

    test('mpin, confirmMpin and otp', () {
      expect(Validators.mpin('123456'), isNull);
      expect(Validators.mpin('12345a'), isNotNull);
      expect(Validators.mpin(''), 'MPIN is required');
      expect(Validators.confirmMpin('123456', '123456'), isNull);
      expect(Validators.confirmMpin('123457', '123456'), 'MPINs do not match');
      expect(Validators.otp('000123'), isNull);
      expect(Validators.otp('123'), isNotNull);
    });

    test('quantity respects minimum order quantity and the maximum', () {
      expect(Validators.quantity(10, minOrderQty: 10), isNull);
      expect(Validators.quantity(9, minOrderQty: 10), 'Minimum order quantity is 10');
      expect(Validators.quantity(100001, minOrderQty: 1), isNotNull);
      expect(Validators.quantity(null, minOrderQty: 1), 'Enter a quantity');
    });

    test('combine returns the first error', () {
      final validate = Validators.combine([
        (v) => Validators.required(v, field: 'Notes'),
        (v) => Validators.maxLength(v, 5, field: 'Notes'),
      ]);
      expect(validate(''), 'Notes is required');
      expect(validate('too long'), 'Notes must be at most 5 characters');
      expect(validate('ok'), isNull);
    });
  });
}
