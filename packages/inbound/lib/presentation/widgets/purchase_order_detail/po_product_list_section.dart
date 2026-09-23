import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:inbound/domain/entities/po_item.dart';

class PoProductListSection extends StatelessWidget {
  const PoProductListSection({
    super.key,
    required this.products,
    required this.isCompleted,
    required this.onProductTap,
  });

  final List<PoItem> products;
  final bool isCompleted;
  final ValueChanged<PoItem> onProductTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Product List', style: WHTypography.heading2),
        const SizedBox(height: 4),
        isCompleted
            ? Text('Click to see QC result.', style: WHTypography.caption)
            : const SizedBox.shrink(),
        const SizedBox(height: 10),
        ...products.map(
          (product) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ProductTile(
              product: product,
              isCompleted: isCompleted,
              onTap: () => onProductTap(product),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.isCompleted,
    required this.onTap,
  });

  final PoItem product;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final qcStyle = _QcTileStyle.fromStatus(product.qcStatus);
    final productCode =
        product.sku ?? 'PRD-${product.productId.toString().padLeft(4, '0')}';
    final productName = product.productName ?? 'Product #${product.productId}';

    return Material(
      color: isCompleted ? qcStyle.backgroundColor : WHColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isCompleted ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCompleted ? qcStyle.borderColor : WHColors.grey5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productCode,
                      style: WHTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: WHColors.grey2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WHTypography.bodyText.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Qty', style: WHTypography.caption),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        product.qtyExpected.toString(),
                        style: WHTypography.bodyText.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.productDetail?.unitOfMeasure ?? '',
                        style: WHTypography.caption.copyWith(
                          color: WHColors.grey2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QcTileStyle {
  const _QcTileStyle({
    required this.backgroundColor,
    required this.borderColor,
  });

  final Color backgroundColor;
  final Color borderColor;

  factory _QcTileStyle.fromStatus(String? status) {
    switch (status?.trim().toLowerCase()) {
      case 'damage':
        return const _QcTileStyle(
          backgroundColor: WHColors.warning4,
          borderColor: WHColors.warning3,
        );
      case 'less':
        return const _QcTileStyle(
          backgroundColor: WHColors.error4,
          borderColor: WHColors.error3,
        );
      case 'success':
      default:
        return const _QcTileStyle(
          backgroundColor: WHColors.success4,
          borderColor: WHColors.success3,
        );
    }
  }
}
