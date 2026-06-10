import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class PaScanCard extends StatelessWidget {
  const PaScanCard({super.key});

  Widget _buildScan() {
    return Container(
      decoration: BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: WHColors.grey3, width: 6)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: WHColors.secondary3),
              const SizedBox(width: 8),
              Text('Zone B - Aisle 3 - Shelf 2', style: WHTypography.heading1),
            ],
          ),
          Text('Required Item', style: WHTypography.caption),
          Text('50 pcs', style: WHTypography.caption),

          const SizedBox(height: 8),

          Text(
            'Scan the location barcode to confirm put away',
            style: WHTypography.caption,
          ),
          WHButton(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Scan',
            backgroundColor: WHColors.primary1,
            onPressed: () {
              // Implement scan functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompleted() {
    return Container(
      decoration: BoxDecoration(
        color: WHColors.success4,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: WHColors.success2, width: 6)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: WHColors.success1),
              const SizedBox(width: 8),
              Text('Zone B - Aisle 3 - Shelf 2', style: WHTypography.heading1),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: WHColors.success1,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Completed',
              style: WHTypography.caption.copyWith(color: WHColors.surface),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildScan();
  }
}
