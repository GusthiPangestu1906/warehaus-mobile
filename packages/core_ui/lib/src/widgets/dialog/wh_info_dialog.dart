import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

/// Reusable information confirmation dialog.
class WHInfoDialog extends StatelessWidget {
  const WHInfoDialog({
    super.key,
    required this.title,
    required this.identifier,
    this.confirmLabel = 'Save',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isLoading = false,
  });

  final String title;
  final String identifier;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isLoading;

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String identifier,
    String confirmLabel = 'Save',
    String cancelLabel = 'Cancel',
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
      builder: (ctx) => WHInfoDialog(
        title: title,
        identifier: identifier,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: WHColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _InfoIcon(),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: WHTypography.bodyText.copyWith(
                color: WHColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              identifier,
              textAlign: TextAlign.center,
              style: WHTypography.heading2.copyWith(
                color: WHColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            WHButton(
              label: confirmLabel,
              backgroundColor: WHColors.primary3,
              isLoading: isLoading,
              onPressed: onConfirm,
            ),
            const SizedBox(height: 10),
            WHOutlinedButton(
              label: cancelLabel,
              borderColor: WHColors.grey1,
              onPressed: onCancel,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoIcon extends StatelessWidget {
  const _InfoIcon();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.warning_amber_rounded,
        color: WHColors.error2,
        size: 128,
      ),
    );
  }
}
