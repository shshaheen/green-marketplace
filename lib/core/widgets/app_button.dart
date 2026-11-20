import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, text }

/// The app's button. Shows a spinner and ignores taps while [isLoading].
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  /// Full width when true; otherwise sized to its content.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final onTap = isLoading ? null : onPressed;
    final child = isLoading
        ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
        : Text(label);

    final button = switch (variant) {
      AppButtonVariant.primary =>
        icon == null
            ? FilledButton(onPressed: onTap, child: child)
            : FilledButton.icon(onPressed: onTap, icon: Icon(icon), label: child),
      AppButtonVariant.secondary =>
        icon == null
            ? OutlinedButton(onPressed: onTap, child: child)
            : OutlinedButton.icon(onPressed: onTap, icon: Icon(icon), label: child),
      AppButtonVariant.text =>
        icon == null
            ? TextButton(onPressed: onTap, child: child)
            : TextButton.icon(onPressed: onTap, icon: Icon(icon), label: child),
    };

    return Semantics(
      button: true,
      label: isLoading ? '$label, loading' : null,
      child: expand && variant != AppButtonVariant.text
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}
