import 'package:flutter/material.dart';

import '../../domain/enums/order_request_status.dart';
import '../../domain/enums/plant_enums.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Small coloured label. Use the named constructors so colours stay consistent.
class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.label, required this.color, super.key});

  factory StatusBadge.orderRequest(OrderRequestStatus status, {Key? key}) =>
      StatusBadge(key: key, label: status.label, color: orderRequestStatusColor(status));

  factory StatusBadge.availability(Availability availability, {Key? key}) =>
      StatusBadge(key: key, label: availability.label, color: availabilityColor(availability));

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.badgeRadius),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
    );
  }
}

/// Exhaustive: adding a status without a colour is a compile error.
Color orderRequestStatusColor(OrderRequestStatus status) => switch (status) {
  OrderRequestStatus.submitted => AppColors.info,
  OrderRequestStatus.underReview => AppColors.warning,
  OrderRequestStatus.contacted => AppColors.warning,
  OrderRequestStatus.accepted => AppColors.primary,
  OrderRequestStatus.completed => AppColors.success,
  OrderRequestStatus.rejected => AppColors.error,
  OrderRequestStatus.cancelled => AppColors.neutral,
};

Color availabilityColor(Availability availability) => switch (availability) {
  Availability.inStock => AppColors.success,
  Availability.limited => AppColors.warning,
  Availability.outOfStock => AppColors.neutral,
};
