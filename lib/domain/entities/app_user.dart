/// Signed-in customer account.
class CustomerAccount {
  const CustomerAccount({
    required this.id,
    required this.email,
    required this.createdAt,
    this.lastLoginAt,
  });

  final String id;
  final String email;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
}

/// Signed-in administrator. Admin accounts are created by the nursery owner only.
class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.isInitialPinSet,
    this.lastLoginAt,
  });

  final String id;
  final String name;
  final String email;

  /// False until the admin completes the email OTP + MPIN initial setup.
  final bool isInitialPinSet;
  final DateTime? lastLoginAt;
}
