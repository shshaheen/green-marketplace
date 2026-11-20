/// Every API path, relative to `EnvConfig.apiBaseUrl` (`<origin>/api/v1`).
/// Mirrors the backend routes in `green_marketplace_backend/src/routes/index.ts`.
abstract final class ApiEndpoints {
  // Public catalogue
  static const String categories = '/categories';
  static const String plants = '/plants';
  static String plant(String idOrSlug) => '/plants/$idOrSlug';

  // Customer auth
  static const String customerAuth = '/auth/customer';
  static const String customerRegisterSendOtp = '$customerAuth/register/send-otp';
  static const String customerRegisterVerifyOtp = '$customerAuth/register/verify-otp';
  static const String customerRegisterSetPin = '$customerAuth/register/set-pin';
  static const String customerLogin = '$customerAuth/login';
  static const String customerForgotPinSendOtp = '$customerAuth/forgot-pin/send-otp';
  static const String customerForgotPinVerifyOtp = '$customerAuth/forgot-pin/verify-otp';
  static const String customerForgotPinReset = '$customerAuth/forgot-pin/reset';
  static const String customerRefresh = '$customerAuth/refresh';
  static const String customerLogout = '$customerAuth/logout';
  static const String customerMe = '$customerAuth/me';

  // Customer Order Requests (customer login required)
  static const String orderRequests = '/order-requests';
  static const String myOrderRequests = '/order-requests/mine';
  static String myOrderRequest(String referenceNumber) => '/order-requests/mine/$referenceNumber';
  static String cancelOrderRequest(String referenceNumber) =>
      '/order-requests/$referenceNumber/cancel';

  // Admin auth
  static const String adminAuth = '/auth/admin';
  static const String adminLogin = '$adminAuth/login';
  static const String adminInitialPinSendOtp = '$adminAuth/initial-pin/send-otp';
  static const String adminInitialPinVerifyOtp = '$adminAuth/initial-pin/verify-otp';
  static const String adminInitialPinSetPin = '$adminAuth/initial-pin/set-pin';
  static const String adminForgotPinSendOtp = '$adminAuth/forgot-pin/send-otp';
  static const String adminForgotPinVerifyOtp = '$adminAuth/forgot-pin/verify-otp';
  static const String adminForgotPinReset = '$adminAuth/forgot-pin/reset';
  static const String adminRefresh = '$adminAuth/refresh';
  static const String adminLogout = '$adminAuth/logout';
  static const String adminMe = '$adminAuth/me';

  // Admin dashboard
  static const String adminDashboardStats = '/admin/dashboard/stats';

  // Admin categories
  static const String adminCategories = '/admin/categories';
  static String adminCategory(String id) => '/admin/categories/$id';

  // Admin plants and images
  static const String adminPlants = '/admin/plants';
  static String adminPlant(String id) => '/admin/plants/$id';
  static String adminPlantStatus(String id) => '/admin/plants/$id/status';
  static String adminPlantImages(String id) => '/admin/plants/$id/images';
  static String adminPlantImageOrder(String id) => '/admin/plants/$id/images/order';
  static String adminPlantImage(String id, String imageId) => '/admin/plants/$id/images/$imageId';

  // Admin Order Requests
  static const String adminOrderRequests = '/admin/order-requests';
  static String adminOrderRequest(String id) => '/admin/order-requests/$id';
  static String adminOrderRequestStatus(String id) => '/admin/order-requests/$id/status';
  static String adminOrderRequestNotes(String id) => '/admin/order-requests/$id/notes';
}
