import '../entities/app_user.dart';

/// Result of sending an OTP email.
class OtpDispatch {
  const OtpDispatch({required this.cooldownSeconds});

  /// Seconds before another code can be requested.
  final int cooldownSeconds;
}

/// Proof that an email was verified by OTP, used to set or reset an MPIN.
/// Short-lived and single-use.
class EmailVerification {
  const EmailVerification({required this.email, required this.verificationToken});

  final String email;
  final String verificationToken;
}

/// Customer accounts: email OTP registration, email + MPIN login, MPIN reset.
///
/// Every method throws an `AppFailure` on error.
abstract interface class CustomerAuthRepository {
  Future<OtpDispatch> sendRegistrationOtp(String email);

  Future<EmailVerification> verifyRegistrationOtp({required String email, required String otp});

  /// Creates the account and signs the customer in.
  Future<CustomerAccount> completeRegistration({
    required EmailVerification verification,
    required String mpin,
    required String confirmMpin,
  });

  Future<CustomerAccount> login({required String email, required String mpin});

  Future<OtpDispatch> sendForgotPinOtp(String email);

  Future<EmailVerification> verifyForgotPinOtp({required String email, required String otp});

  /// Sets a new MPIN and ends existing sessions. The customer logs in again afterwards.
  Future<void> resetPin({
    required EmailVerification verification,
    required String mpin,
    required String confirmMpin,
  });

  /// The signed-in customer, or null when there is no valid session.
  Future<CustomerAccount?> currentCustomer();

  Future<void> logout();
}

/// Administrator accounts: pre-created only (no sign-up). Email + MPIN login,
/// initial MPIN setup and MPIN reset via email OTP.
///
/// Every method throws an `AppFailure` on error.
abstract interface class AdminAuthRepository {
  Future<AdminUser> login({required String email, required String mpin});

  Future<OtpDispatch> sendInitialPinOtp(String email);

  Future<EmailVerification> verifyInitialPinOtp({required String email, required String otp});

  /// Sets the first MPIN for a pre-created admin and signs them in.
  Future<AdminUser> setInitialPin({
    required EmailVerification verification,
    required String mpin,
    required String confirmMpin,
  });

  Future<OtpDispatch> sendForgotPinOtp(String email);

  Future<EmailVerification> verifyForgotPinOtp({required String email, required String otp});

  Future<void> resetPin({
    required EmailVerification verification,
    required String mpin,
    required String confirmMpin,
  });

  /// The signed-in admin, or null when there is no valid admin session.
  Future<AdminUser?> currentAdmin();

  Future<void> logout();
}
