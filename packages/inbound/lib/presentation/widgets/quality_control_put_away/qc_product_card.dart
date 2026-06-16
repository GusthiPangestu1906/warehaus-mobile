import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class QcProductCard extends StatelessWidget {
  const QcProductCard({
    super.key,
    required this.sku,
    required this.productName,
    required this.expectedQty,
    this.unitOfMeasure = 'Box',
  });

  final String sku;
  final String productName;
  final int expectedQty;
  final String unitOfMeasure;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: WHColors.secondary6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sku,
            style: WHTypography.bodyText.copyWith(
              color: WHColors.secondary1,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            productName,
            style: WHTypography.heading2.copyWith(
              color: WHColors.secondary1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Expected Qty: $expectedQty $unitOfMeasure',
            style: WHTypography.bodyText.copyWith(
              color: WHColors.secondary1,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
