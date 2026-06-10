// lib/core_ui/lib/src/components/wh_progress_card.dart

import 'package:core_ui/core_ui.dart'; // WHColors, WHTypography
import 'package:flutter/material.dart';

/// Header untuk tampilan quality control — reusable untuk PO maupun SO.
///
/// Usage:
/// ```dart
/// // Purchase Order
/// QcHeader(
///   typeLabel: 'PURCHASE ORDER',
///   orderNumber: 'PO-9805-Y',
///   currentItem: 1,
///   totalItems: 4,
/// )
///
/// // Sales Order dengan warna kustom
/// QcHeader(
///   typeLabel: 'SALES ORDER',
///   orderNumber: 'SO-2026-089',
///   currentItem: 32,
///   totalItems: 45,
///   itemUnit: 'Pallets',
///   progressColor: WHColors.primary3,
/// )
/// ```
class QcHeader extends StatelessWidget {
  const QcHeader({
    super.key,
    required this.typeLabel,
    required this.orderNumber,
    required this.currentItem,
    required this.totalItems,
    this.itemUnit = 'Items',
    this.progressColor = WHColors.secondary3,
    this.onTap,
  });

  /// Label tipe order. Contoh: "PURCHASE ORDER", "SALES ORDER"
  final String typeLabel;

  /// Nomor order. Contoh: "PO-9805-Y"
  final String orderNumber;

  /// Jumlah item yang sudah diproses
  final int currentItem;

  /// Total item keseluruhan
  final int totalItems;

  /// Satuan item. Default: "Items"
  final String itemUnit;

  /// Warna progress bar & counter. Default: WHColors.secondary3 (oranye)
  final Color progressColor;

  final VoidCallback? onTap;

  double get _progress =>
      totalItems > 0 ? (currentItem / totalItems).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: WHColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: WHColors.grey5, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Row atas: type label + order number ───────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  typeLabel,
                  style: WHTypography.caption.copyWith(
                    color: WHColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  orderNumber,
                  style: WHTypography.caption.copyWith(
                    color: WHColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── Row bawah: progress bar + counter ─────────────
            Row(
              children: [
                // Progress bar
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 5,
                      backgroundColor: WHColors.grey5,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Counter: "1 / 4 Items"
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$currentItem / $totalItems ',
                        style: WHTypography.caption.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: itemUnit,
                        style: WHTypography.caption.copyWith(
                          color: WHColors.secondary3,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
