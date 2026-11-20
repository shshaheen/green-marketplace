import '../../domain/entities/draft_request_item.dart' as domain;

/// App-wide constants. Business limits mirror the backend's validation rules.
abstract final class AppConstants {
  static const String appName = 'Green Marketplace';

  // Networking
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 2);

  // Lists
  static const int defaultPageSize = 20;

  // Authentication
  static const int mpinLength = 6;
  static const int otpLength = 6;
  static const int defaultOtpResendCooldownSeconds = 60;

  // Order Requests
  static const int maxItemsPerRequest = domain.maxItemsPerRequest;
  static const int maxQuantityPerItem = domain.maxQuantityPerItem;
  static const int maxNotesLength = 1000;
  static const int maxNameLength = 100;
  static const int maxLocationLength = 200;

  // Plants
  static const int maxImagesPerPlant = 10;
  static const int maxImageBytes = 5 * 1024 * 1024;
}
