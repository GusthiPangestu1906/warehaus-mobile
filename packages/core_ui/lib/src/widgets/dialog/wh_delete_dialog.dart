// lib/core_ui/lib/src/components/wh_delete_dialog.dart

import 'package:core_ui/core_ui.dart'; // WHColors, WHTypography, WHButton, WHOutlinedButton
import 'package:flutter/material.dart';

/// Dialog konfirmasi hapus yang reusable.
///
/// Usage — cara 1: fungsi helper (direkomendasikan)
/// ```dart
/// final confirmed = await WHDeleteDialog.show(
///   context: context,
///   title: 'Are you sure want to delete this Purchase Order?',
///   identifier: 'PO-08092026-01',
/// );
/// if (confirmed == true) {
///   // lanjutkan proses hapus
/// }
/// ```
///
/// Usage — cara 2: langsung sebagai widget
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => WHDeleteDialog(
///     title: 'Are you sure want to delete this Purchase Order?',
///     identifier: 'PO-08092026-01',
///     onConfirm: () => Navigator.pop(context, true),
///     onCancel: () => Navigator.pop(context, false),
///   ),
/// );
/// ```
class WHDeleteDialog extends StatelessWidget {
  const WHDeleteDialog({
    super.key,
    required this.title,
    required this.identifier,
    this.confirmLabel = 'Delete',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isLoading = false,
  });

  /// Kalimat pertanyaan konfirmasi.
  /// Contoh: "Are you sure want to delete this Purchase Order?"
  final String title;

  /// Nama/ID item yang akan dihapus — ditampilkan bold di bawah [title].
  /// Contoh: "PO-08092026-01"
  final String identifier;

  /// Label tombol konfirmasi. Default: "Delete"
  final String confirmLabel;

  /// Label tombol batal. Default: "Cancel"
  final String cancelLabel;

  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  /// Tampilkan loading spinner pada tombol konfirmasi
  final bool isLoading;

  // ── Static helper ───────────────────────────────────────────
  /// Menampilkan dialog dan mengembalikan `true` jika dikonfirmasi,
  /// `false` jika dibatalkan, `null` jika ditutup paksa.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String identifier,
    String confirmLabel = 'Delete',
    String cancelLabel = 'Cancel',
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
      builder: (ctx) => WHDeleteDialog(
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
            // ── Warning icon ─────────────────────────────────
            _WarningIcon(),

            const SizedBox(height: 20),

            // ── Title ────────────────────────────────────────
            Text(
              title,
              textAlign: TextAlign.center,
              style: WHTypography.bodyText.copyWith(
                color: WHColors.textSecondary,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 6),

            // ── Identifier ───────────────────────────────────
            Text(
              identifier,
              textAlign: TextAlign.center,
              style: WHTypography.heading2.copyWith(
                color: WHColors.textPrimary,
              ),
            ),

            const SizedBox(height: 24),

            // ── Delete button ────────────────────────────────
            WHButton(
              label: confirmLabel,
              backgroundColor: WHColors.error2,
              isLoading: isLoading,
              onPressed: onConfirm,
            ),

            const SizedBox(height: 10),

            // ── Cancel button ────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────
// Warning icon widget
// ─────────────────────────────────────────────────────────────────
class _WarningIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.warning_amber_rounded,
        color: WHColors.error2,
        size: 128,
      ),
    );
  }
}
