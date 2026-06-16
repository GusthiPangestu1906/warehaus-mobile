import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class UpcomingProductCard extends StatelessWidget {
  const UpcomingProductCard({required this.product, super.key});

  final UpcomingProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: WHColors.grey5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.sku,
                  style: WHTypography.caption.copyWith(color: WHColors.grey2),
                ),
                Text(
                  product.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: WHTypography.bodyText.copyWith(
                    color: WHColors.grey2,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'QTY',
                style: WHTypography.caption.copyWith(color: WHColors.grey2),
              ),
              Text(
                '${product.expectedQty} ${product.unit}',
                style: WHTypography.bodyText.copyWith(
                  color: WHColors.grey2,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UpcomingProduct {
  final String sku;
  final String productName;
  final int expectedQty;
  final String unit;

  UpcomingProduct({
    required this.sku,
    required this.productName,
    required this.expectedQty,
    this.unit = 'Box',
  });
}
