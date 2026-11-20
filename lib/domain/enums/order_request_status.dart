/// Order Request lifecycle. Transition rules mirror the backend
/// (`orderRequest.constants.ts`); the backend still enforces them.
///
/// ```
/// submitted → underReview → contacted → accepted → completed
/// submitted / underReview / contacted → rejected   (admin)
/// submitted / underReview / contacted → cancelled  (customer)
/// accepted → cancelled                              (admin, note required)
/// ```
enum OrderRequestStatus {
  submitted('submitted', 'Submitted'),
  underReview('under_review', 'Under Review'),
  contacted('contacted', 'Contacted'),
  accepted('accepted', 'Accepted'),
  completed('completed', 'Completed'),
  rejected('rejected', 'Rejected'),
  cancelled('cancelled', 'Cancelled');

  const OrderRequestStatus(this.apiValue, this.label);

  /// Value used by the API.
  final String apiValue;

  /// Text shown to users.
  final String label;

  static OrderRequestStatus fromApi(String value) => values.firstWhere(
    (status) => status.apiValue == value,
    orElse: () => throw FormatException('Unknown Order Request status: $value'),
  );

  /// Statuses an admin may move to next. Empty for final statuses.
  List<OrderRequestStatus> get allowedNextStatuses => switch (this) {
    submitted => const [underReview, rejected],
    underReview => const [contacted, rejected],
    contacted => const [accepted, rejected],
    accepted => const [completed, cancelled],
    completed || rejected || cancelled => const [],
  };

  bool canTransitionTo(OrderRequestStatus next) => allowedNextStatuses.contains(next);

  /// Whether an admin must give a reason for moving to [next].
  bool requiresNoteFor(OrderRequestStatus next) => this == accepted && next == cancelled;

  /// Customers may cancel only before the request is accepted.
  bool get canCustomerCancel => this == submitted || this == underReview || this == contacted;

  bool get isFinal => allowedNextStatuses.isEmpty;
}
