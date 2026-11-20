import 'package:flutter_test/flutter_test.dart';
import 'package:green_marketplace/domain/enums/order_request_status.dart';

void main() {
  group('OrderRequestStatus', () {
    test('parses API values', () {
      expect(OrderRequestStatus.fromApi('under_review'), OrderRequestStatus.underReview);
      expect(() => OrderRequestStatus.fromApi('shipped'), throwsFormatException);
    });

    test('admin transitions follow the backend lifecycle', () {
      expect(OrderRequestStatus.submitted.allowedNextStatuses, [
        OrderRequestStatus.underReview,
        OrderRequestStatus.rejected,
      ]);
      expect(OrderRequestStatus.underReview.allowedNextStatuses, [
        OrderRequestStatus.contacted,
        OrderRequestStatus.rejected,
      ]);
      expect(OrderRequestStatus.contacted.allowedNextStatuses, [
        OrderRequestStatus.accepted,
        OrderRequestStatus.rejected,
      ]);
      expect(OrderRequestStatus.accepted.allowedNextStatuses, [
        OrderRequestStatus.completed,
        OrderRequestStatus.cancelled,
      ]);
      for (final status in [
        OrderRequestStatus.completed,
        OrderRequestStatus.rejected,
        OrderRequestStatus.cancelled,
      ]) {
        expect(status.isFinal, isTrue);
      }
    });

    test('no skipping steps or going backwards', () {
      expect(OrderRequestStatus.submitted.canTransitionTo(OrderRequestStatus.contacted), isFalse);
      expect(OrderRequestStatus.contacted.canTransitionTo(OrderRequestStatus.underReview), isFalse);
      expect(OrderRequestStatus.submitted.canTransitionTo(OrderRequestStatus.cancelled), isFalse);
    });

    test('note required only when cancelling an accepted request', () {
      expect(OrderRequestStatus.accepted.requiresNoteFor(OrderRequestStatus.cancelled), isTrue);
      expect(OrderRequestStatus.contacted.requiresNoteFor(OrderRequestStatus.rejected), isFalse);
    });

    test('customers can cancel only before acceptance', () {
      final cancellable = OrderRequestStatus.values.where((s) => s.canCustomerCancel);
      expect(cancellable, [
        OrderRequestStatus.submitted,
        OrderRequestStatus.underReview,
        OrderRequestStatus.contacted,
      ]);
    });
  });
}
