import '../config/app_constants.dart';

/// Form validators. Each returns an error message, or null when the value is valid.
/// Rules mirror the backend so most mistakes are caught before a request is sent.
abstract final class Validators {
  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final RegExp _mobile = RegExp(r'^[6-9]\d{9}$');
  static final RegExp _pincode = RegExp(r'^[1-9]\d{5}$');
  static final RegExp _sixDigits = RegExp(r'^\d{6}$');

  static String? required(String? value, {String field = 'This field'}) =>
      (value == null || value.trim().isEmpty) ? '$field is required' : null;

  static String? maxLength(String? value, int max, {String field = 'This field'}) =>
      (value != null && value.trim().length > max)
      ? '$field must be at most $max characters'
      : null;

  static String? email(String? value) {
    final error = required(value, field: 'Email');
    if (error != null) return error;
    return _email.hasMatch(value!.trim()) ? null : 'Enter a valid email address';
  }

  /// Empty is allowed; a non-empty value must be a valid email.
  static String? optionalEmail(String? value) =>
      (value == null || value.trim().isEmpty) ? null : email(value);

  /// Removes spaces, dashes and a leading +91 / 91 / 0 from an Indian mobile number.
  static String normalizeMobile(String value) =>
      value.replaceAll(RegExp(r'[\s-]'), '').replaceFirst(RegExp(r'^(\+91|91|0)(?=\d{10}$)'), '');

  static String? mobile(String? value) {
    final error = required(value, field: 'Mobile number');
    if (error != null) return error;
    return _mobile.hasMatch(normalizeMobile(value!))
        ? null
        : 'Enter a valid 10-digit mobile number';
  }

  static String? pincode(String? value) {
    final error = required(value, field: 'PIN code');
    if (error != null) return error;
    return _pincode.hasMatch(value!.trim()) ? null : 'Enter a valid 6-digit PIN code';
  }

  static String? mpin(String? value) {
    if (value == null || value.isEmpty) return 'MPIN is required';
    return _sixDigits.hasMatch(value)
        ? null
        : 'MPIN must be exactly ${AppConstants.mpinLength} digits';
  }

  static String? confirmMpin(String? value, String original) {
    final error = mpin(value);
    if (error != null) return error;
    return value == original ? null : 'MPINs do not match';
  }

  static String? otp(String? value) {
    if (value == null || value.isEmpty) return 'Enter the code from your email';
    return _sixDigits.hasMatch(value) ? null : 'The code has ${AppConstants.otpLength} digits';
  }

  /// Quantity must be a whole number between the plant's minimum order quantity
  /// and the per-item maximum.
  static String? quantity(int? value, {required int minOrderQty}) {
    if (value == null) return 'Enter a quantity';
    if (value < minOrderQty) return 'Minimum order quantity is $minOrderQty';
    if (value > AppConstants.maxQuantityPerItem) {
      return 'Maximum quantity is ${AppConstants.maxQuantityPerItem}';
    }
    return null;
  }

  /// Runs validators in order and returns the first error.
  static String? Function(String?) combine(List<String? Function(String?)> validators) => (value) {
    for (final validate in validators) {
      final error = validate(value);
      if (error != null) return error;
    }
    return null;
  };
}
