import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_marketplace/core/error/failures.dart';
import 'package:green_marketplace/core/theme/app_theme.dart';
import 'package:green_marketplace/core/widgets/app_button.dart';
import 'package:green_marketplace/core/widgets/app_text_field.dart';
import 'package:green_marketplace/core/widgets/async_state_view.dart';
import 'package:green_marketplace/core/widgets/confirm_dialog.dart';
import 'package:green_marketplace/core/widgets/status_badge.dart';
import 'package:green_marketplace/domain/enums/order_request_status.dart';
import 'package:green_marketplace/domain/enums/plant_enums.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: child),
);

void main() {
  group('AsyncStateView', () {
    Widget view(AsyncValue<List<int>> value, {VoidCallback? onRetry}) => _wrap(
      AsyncStateView<List<int>>(
        value: value,
        isEmpty: (items) => items.isEmpty,
        emptyMessage: 'No plants found',
        onRetry: onRetry,
        builder: (items) => Text('Items: ${items.length}'),
      ),
    );

    testWidgets('loading, data, empty and error states', (tester) async {
      await tester.pumpWidget(view(const AsyncLoading()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(view(const AsyncData([1, 2])));
      expect(find.text('Items: 2'), findsOneWidget);

      await tester.pumpWidget(view(const AsyncData([])));
      expect(find.text('No plants found'), findsOneWidget);

      var retried = false;
      await tester.pumpWidget(
        view(const AsyncError(NetworkFailure(), StackTrace.empty), onRetry: () => retried = true),
      );
      expect(find.text(const NetworkFailure().message), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });

    testWidgets('non-AppFailure errors show a generic message', (tester) async {
      await tester.pumpWidget(view(AsyncError(Exception('secret detail'), StackTrace.empty)));
      expect(find.textContaining('secret'), findsNothing);
      expect(find.text(const UnknownFailure().message), findsOneWidget);
    });
  });

  testWidgets('AppButton ignores taps while loading', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(AppButton(label: 'Submit Request', onPressed: () => taps++)));
    await tester.tap(find.text('Submit Request'));
    expect(taps, 1);

    await tester.pumpWidget(
      _wrap(AppButton(label: 'Submit Request', isLoading: true, onPressed: () => taps++)),
    );
    await tester.tap(find.byType(FilledButton));
    expect(taps, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AppTextField toggles obscured MPIN text', (tester) async {
    await tester.pumpWidget(_wrap(const AppTextField(label: 'MPIN', obscurable: true)));
    EditableText editable() => tester.widget<EditableText>(find.byType(EditableText));
    expect(editable().obscureText, isTrue);
    await tester.tap(find.byTooltip('Show'));
    await tester.pump();
    expect(editable().obscureText, isFalse);
  });

  testWidgets('StatusBadge labels', (tester) async {
    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            StatusBadge.orderRequest(OrderRequestStatus.underReview),
            StatusBadge.availability(Availability.outOfStock),
          ],
        ),
      ),
    );
    expect(find.text('Under Review'), findsOneWidget);
    expect(find.text('Unavailable'), findsOneWidget);
  });

  testWidgets('showConfirmDialog resolves true only on confirm', (tester) async {
    bool? result;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await showConfirmDialog(
              context,
              title: 'Cancel Request?',
              message: 'This cannot be undone.',
              isDestructive: true,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isFalse);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}
