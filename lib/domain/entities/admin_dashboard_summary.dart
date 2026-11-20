import '../enums/order_request_status.dart';
import 'money.dart';

class TopRequestedPlant {
  const TopRequestedPlant({
    required this.plantId,
    required this.plantName,
    required this.requestCount,
    required this.totalQuantity,
  });

  final String plantId;
  final String plantName;
  final int requestCount;
  final int totalQuantity;
}

/// Row in admin lists and the dashboard's recent requests.
class OrderRequestSummary {
  const OrderRequestSummary({
    required this.id,
    required this.referenceNumber,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.itemCount,
    required this.totalQuantity,
    required this.estimatedTotal,
    required this.createdAt,
    this.customerEmail,
    this.location,
    this.pincode,
    this.preferredDeliveryDate,
  });

  final String id;
  final String referenceNumber;
  final OrderRequestStatus status;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String? location;
  final String? pincode;
  final int itemCount;
  final int totalQuantity;

  /// Indicative only.
  final Money estimatedTotal;
  final DateTime? preferredDeliveryDate;
  final DateTime createdAt;
}

/// `GET /admin/dashboard/stats`.
class AdminDashboardSummary {
  const AdminDashboardSummary({
    required this.totalRequests,
    required this.newRequests,
    required this.byStatus,
    required this.receivedToday,
    required this.receivedLast7Days,
    required this.receivedLast30Days,
    required this.activePlants,
    required this.outOfStockPlants,
    required this.topRequestedPlants,
    required this.recentRequests,
  });

  final int totalRequests;

  /// Requests with status `submitted`.
  final int newRequests;
  final Map<OrderRequestStatus, int> byStatus;
  final int receivedToday;
  final int receivedLast7Days;
  final int receivedLast30Days;
  final int activePlants;
  final int outOfStockPlants;
  final List<TopRequestedPlant> topRequestedPlants;
  final List<OrderRequestSummary> recentRequests;

  int countFor(OrderRequestStatus status) => byStatus[status] ?? 0;
}
