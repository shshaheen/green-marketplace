import '../entities/draft_request_item.dart';
import '../entities/order_request.dart';
import '../entities/paginated.dart';
import '../enums/intended_use.dart';
import '../enums/order_request_status.dart';

/// What the customer fills in to Submit Request. The account email comes from the
/// signed-in session, so it is not part of this input.
class SubmitOrderRequestInput {
  const SubmitOrderRequestInput({
    required this.name,
    required this.phone,
    required this.location,
    required this.pincode,
    required this.intendedUse,
    required this.items,
    this.preferredDeliveryDate,
    this.additionalNotes,
  });

  final String name;
  final String phone;
  final String location;
  final String pincode;
  final IntendedUse intendedUse;
  final List<DraftRequestItem> items;
  final DateTime? preferredDeliveryDate;
  final String? additionalNotes;
}

/// The signed-in customer's Order Requests ("My Requests"), plus the local draft.
/// Throws `AppFailure` on error.
abstract interface class OrderRequestRepository {
  /// Requires a customer session. Returns the created request with its reference number.
  Future<OrderRequest> submit(SubmitOrderRequestInput input);

  Future<Paginated<OrderRequest>> getMyRequests({
    int page = 1,
    int limit = 20,
    OrderRequestStatus? status,
  });

  Future<OrderRequest> getMyRequest(String referenceNumber);

  /// Allowed only before the request is accepted.
  Future<OrderRequest> cancel(String referenceNumber, {String? reason});

  // Draft (stored on the device, works without login)

  Future<List<DraftRequestItem>> loadDraft();

  Future<void> saveDraft(List<DraftRequestItem> items);

  Future<void> clearDraft();
}
