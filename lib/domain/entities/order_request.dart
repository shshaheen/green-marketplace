import '../enums/intended_use.dart';
import '../enums/order_request_status.dart';
import '../enums/plant_enums.dart';
import 'money.dart';

/// Contact and delivery details given with an Order Request.
class CustomerDetails {
  const CustomerDetails({
    required this.name,
    required this.phone,
    required this.location,
    required this.pincode,
    this.email,
  });

  final String name;
  final String phone;
  final String? email;
  final String location;
  final String pincode;
}

/// A requested plant, with the catalogue details copied at submission time.
/// These snapshots never change, even if the plant is later edited or deleted.
class OrderRequestItem {
  const OrderRequestItem({
    required this.plantId,
    required this.plantName,
    required this.quantity,
    required this.unit,
    required this.indicativePrice,
    required this.availability,
    this.imageUrl,
  });

  final String plantId;
  final String plantName;
  final int quantity;
  final PriceUnit unit;
  final Money indicativePrice;
  final Availability availability;
  final String? imageUrl;

  Money get lineTotal => indicativePrice * quantity;
}

/// One entry in the status history. [note] and [adminName] are admin-only.
class StatusChange {
  const StatusChange({
    required this.to,
    required this.at,
    this.from,
    this.changedByAdmin,
    this.adminName,
    this.note,
  });

  final OrderRequestStatus? from;
  final OrderRequestStatus to;
  final DateTime at;
  final bool? changedByAdmin;
  final String? adminName;
  final String? note;
}

/// A customer's intention to buy plants. Never a confirmed order: prices are
/// indicative and payment happens offline.
///
/// Customer responses leave admin fields null; admin responses fill [id],
/// [adminNotes] and [allowedTransitions].
class OrderRequest {
  const OrderRequest({
    required this.referenceNumber,
    required this.status,
    required this.items,
    required this.estimatedTotal,
    required this.intendedUse,
    required this.createdAt,
    required this.updatedAt,
    this.id,
    this.customerDetails,
    this.preferredDeliveryDate,
    this.additionalNotes,
    this.statusHistory = const [],
    this.adminNotes,
    this.allowedTransitions = const [],
  });

  final String referenceNumber;
  final OrderRequestStatus status;
  final List<OrderRequestItem> items;

  /// Indicative only.
  final Money estimatedTotal;
  final IntendedUse intendedUse;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? id;
  final CustomerDetails? customerDetails;

  /// Date only (no time).
  final DateTime? preferredDeliveryDate;
  final String? additionalNotes;
  final List<StatusChange> statusHistory;

  // Admin-only fields.
  final String? adminNotes;
  final List<OrderRequestStatus> allowedTransitions;

  bool get canCustomerCancel => status.canCustomerCancel;

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
}
