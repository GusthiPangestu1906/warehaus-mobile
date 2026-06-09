import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:outbound/domain/entities/so_item.dart';

class SoProductListSection extends StatelessWidget {
  const SoProductListSection({super.key, required this.products});

  final List<SoItem> products;

  @override
  Widget build(BuildContext context) {
    final rows = products.isEmpty
        ? const [
            SoItem(productId: 0, qtyOrdered: 230, productName: 'Green Tea 90g'),
            SoItem(productId: 0, qtyOrdered: 230, productName: 'White pepper'),
            SoItem(
              productId: 0,
              qtyOrdered: 230,
              productName: 'Secret Stadium Sauce',
            ),
          ]
        : products;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Product List', style: WHTypography.heading2),
        const SizedBox(height: 8),
        ...rows.map(
          (product) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ProductTile(product: product),
          ),
        ),
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});

  final SoItem product;

  @override
  Widget build(BuildContext context) {
    final productCode = product.productId == 0
        ? 'TEA-GRN-90'
        : 'PRD-${product.productId.toString().padLeft(4, '0')}';
    final productName = product.productName ?? 'Product #${product.productId}';

    return Container(
      padding: const EdgeInsets.all(10),
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
                  productCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: WHTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: WHTypography.bodyText.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'QTY\n${product.qtyOrdered} Box',
            textAlign: TextAlign.right,
            style: WHTypography.bodyText.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
