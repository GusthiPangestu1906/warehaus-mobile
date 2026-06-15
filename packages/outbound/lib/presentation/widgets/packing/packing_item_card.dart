import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class PackingItemCard extends StatelessWidget {
  const PackingItemCard({
    super.key,
    required this.sku,
    required this.productName,
    required this.expectedQty,
    required this.unitOfMeasure,
    required this.isVerified,
    this.onScan,
  });

  final String sku;
  final String productName;
  final int expectedQty;
  final String unitOfMeasure;
  final bool isVerified;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: WHColors.success4,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: WHColors.success2, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sku,
              style: WHTypography.caption.copyWith(
                color: WHColors.textSecondary,
                fontSize: 13,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              productName,
              style: WHTypography.heading2.copyWith(
                color: WHColors.primary1,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Expected Qty: $expectedQty $unitOfMeasure',
              style: WHTypography.bodyText.copyWith(
                color: WHColors.primary1,
                fontSize: 14,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            const VerifiedBadge(),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 32, 16),
      decoration: BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF7B7486), width: 1),
      ),
      foregroundDecoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFF7B7486), width: 4)),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sku,
            style: WHTypography.bodyText.copyWith(
              color: WHColors.primary1,
              fontSize: 16,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            productName,
            style: WHTypography.heading1.copyWith(
              color: WHColors.primary1,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Expected Qty: $expectedQty $unitOfMeasure',
            style: WHTypography.bodyText.copyWith(
              color: WHColors.primary1,
              fontSize: 16,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Verify Barcode Item',
            style: WHTypography.bodyText.copyWith(
              color: WHColors.textSecondary,
              fontSize: 16,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          WHButton(
            label: 'Scan',
            icon: Icons.qr_code_scanner,
            backgroundColor: WHColors.primary1,
            onPressed: onScan,
          ),
        ],
      ),
    );
  }
}
