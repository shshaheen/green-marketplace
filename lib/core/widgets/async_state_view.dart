import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../error/failures.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';

/// One place for loading, empty and error states of an [AsyncValue].
///
/// ```dart
/// AsyncStateView(
///   value: ref.watch(plantsProvider),
///   isEmpty: (plants) => plants.isEmpty,
///   emptyMessage: 'No plants found',
///   onRetry: () => ref.invalidate(plantsProvider),
///   builder: (plants) => PlantGrid(plants),
/// )
/// ```
class AsyncStateView<T> extends StatelessWidget {
  const AsyncStateView({
    required this.value,
    required this.builder,
    super.key,
    this.isEmpty,
    this.emptyMessage = 'Nothing here yet',
    this.emptyIcon = Icons.inbox_outlined,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final bool Function(T data)? isEmpty;
  final String emptyMessage;
  final IconData emptyIcon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      // Keep showing data while refreshing.
      skipLoadingOnRefresh: true,
      data: (data) => (isEmpty?.call(data) ?? false)
          ? _Message(icon: emptyIcon, message: emptyMessage)
          : builder(data),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _Message(
        icon: Icons.error_outline,
        iconColor: AppColors.error,
        message: error is AppFailure ? error.message : const UnknownFailure().message,
        onRetry: onRetry,
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.message, this.iconColor, this.onRetry});

  final IconData icon;
  final String message;
  final Color? iconColor;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: iconColor ?? AppColors.secondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (retry != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Try again',
                variant: AppButtonVariant.secondary,
                expand: false,
                onPressed: retry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
