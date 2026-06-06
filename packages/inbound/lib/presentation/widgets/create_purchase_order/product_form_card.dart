import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:product/domain/entities/product.dart';

class ProductFormCard extends StatelessWidget {
  final List<Product> masterProducts;
  final int? selectedProductId;
  final int quantity;
  final ValueChanged<int?> onProductChanged;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onDelete;

  const ProductFormCard({
    super.key,
    required this.masterProducts,
    required this.selectedProductId,
    required this.quantity,
    required this.onProductChanged,
    required this.onQtyChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WHColors.grey4,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WHDropdownField<int>(
            label: 'Product Name',
            hintText: 'Select Product',
            selectedValue: selectedProductId,
            items: masterProducts.map((p) {
              return WHDropdownItem<int>(
                value: int.tryParse(p.id) ?? 0,
                label: p.productName,
              );
            }).toList(),
            onChanged: onProductChanged,
          ),
          const SizedBox(height: 16),
          WHStepperField(
            label: 'Qty',
            value: quantity,
            minValue: 0,
            onChanged: onQtyChanged,
          ),
          const SizedBox(height: 12),
          const Divider(),
          Center(
            child: WHOutlinedButton(
              label: 'Delete',
              icon: Icons.delete,
              onPressed: onDelete,
              borderColor: WHColors.error2,
            ),
          ),
        ],
      ),
    );
  }
}
