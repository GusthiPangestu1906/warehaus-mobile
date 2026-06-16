import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:inbound/domain/entities/pa_next_item.dart';

class PaScanCard extends StatelessWidget {
  const PaScanCard({
    super.key,
    required this.shelf,
    required this.unitOfMeasure,
    required this.onScan,
    this.isCompleted = false,
  });

  final RecommendedShelf shelf;
  final String unitOfMeasure;
  final VoidCallback onScan;
  final bool isCompleted;

  Widget _buildScan() {
    return Container(
      decoration: BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: WHColors.grey3, width: 6),
          right: BorderSide(color: WHColors.grey3, width: 1),
          top: BorderSide(color: WHColors.grey3, width: 1),
          bottom: BorderSide(color: WHColors.grey3, width: 1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: WHColors.secondary3,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  shelf.displayName.toUpperCase(),
                  style: WHTypography.heading2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'Required Item',
            style: WHTypography.caption.copyWith(color: WHColors.grey1),
          ),
          const SizedBox(height: 2),
          Text(
            '${shelf.qtyRequired} ${unitOfMeasure}',
            style: WHTypography.bodyText.copyWith(
              fontWeight: FontWeight.w600,
              color: WHColors.primary1,
            ),
          ),
          const SizedBox(height: 16),

          // Teks Instruksi Verifikasi
          Text(
            'Verify QR Shelf',
            style: WHTypography.caption.copyWith(color: WHColors.grey1),
          ),
          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: WHButton(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Scan',
              backgroundColor: WHColors.primary1,
              onPressed: onScan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleted() {
    return Container(
      decoration: BoxDecoration(
        color: WHColors.success4,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: WHColors.success2, width: 6),
          right: BorderSide(color: WHColors.success2, width: 1),
          top: BorderSide(color: WHColors.success2, width: 1),
          bottom: BorderSide(color: WHColors.success2, width: 1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: WHColors.success1,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  shelf.displayName.toUpperCase(),
                  style: WHTypography.heading2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: WHColors.success2,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Verified',
                  style: WHTypography.caption.copyWith(
                    color: WHColors.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: WHColors.surface,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isCompleted ? _buildCompleted() : _buildScan();
  }
}
