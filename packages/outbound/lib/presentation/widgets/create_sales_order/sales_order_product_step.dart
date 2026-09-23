import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:outbound/presentation/models/sales_order_product_line.dart';
import 'package:outbound/presentation/widgets/create_sales_order/sales_order_form_styles.dart';

class SalesOrderProductStep extends StatelessWidget {
  final DateTime? requiredDeliveryDate;
  final List<SalesOrderProductLine> lines;
  final List<Map<String, dynamic>> products;
  final bool isLoadingProducts;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onAddProduct;
  final void Function(int index) onDeleteProduct;
  final void Function(int index, int? productId) onProductChanged;
  final void Function(int index, int qty) onQtyChanged;

  const SalesOrderProductStep({
    super.key,
    required this.requiredDeliveryDate,
    required this.lines,
    required this.products,
    required this.isLoadingProducts,
    required this.onDateSelected,
    required this.onAddProduct,
    required this.onDeleteProduct,
    required this.onProductChanged,
    required this.onQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        _DateCard(value: requiredDeliveryDate, onDateSelected: onDateSelected),
        const SizedBox(height: 20),
        const Text(
          'Product List',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        _ProductListPanel(
          lines: lines,
          products: products,
          isLoading: isLoadingProducts,
          onProductChanged: onProductChanged,
          onQtyChanged: onQtyChanged,
          onDelete: onDeleteProduct,
        ),
        const SizedBox(height: 12),
        _AddProductButton(onPressed: onAddProduct),
      ],
    );
  }
}

class _DateCard extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime> onDateSelected;

  const _DateCard({required this.value, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return WHDateField(
      label: 'Required Delivery Date / SLA',
      selectedDate: value,
      onDateSelected: onDateSelected,
      isPast: false,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
  }
}

class _ProductListPanel extends StatelessWidget {
  final List<SalesOrderProductLine> lines;
  final List<Map<String, dynamic>> products;
  final bool isLoading;
  final void Function(int index, int? productId) onProductChanged;
  final void Function(int index, int qty) onQtyChanged;
  final void Function(int index) onDelete;

  const _ProductListPanel({
    required this.lines,
    required this.products,
    required this.isLoading,
    required this.onProductChanged,
    required this.onQtyChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: WHColors.grey5,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          for (var index = 0; index < lines.length; index++) ...[
            if (index > 0) const SizedBox(height: 12),
            _ProductLineCard(
              line: lines[index],
              products: products,
              isLoading: isLoading,
              onProductChanged: (value) => onProductChanged(index, value),
              onQtyChanged: (qty) => onQtyChanged(index, qty),
              onDelete: () => onDelete(index),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductLineCard extends StatelessWidget {
  final SalesOrderProductLine line;
  final List<Map<String, dynamic>> products;
  final bool isLoading;
  final ValueChanged<int?> onProductChanged;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onDelete;

  const _ProductLineCard({
    required this.line,
    required this.products,
    required this.isLoading,
    required this.onProductChanged,
    required this.onQtyChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: salesOrderPlainCardDecoration(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Product Name',
                style: TextStyle(color: WHColors.grey1, fontSize: 16),
              ),
              const SizedBox(height: 8),
              isLoading
                  ? const _LoadingField()
                  : _ProductDropdown(
                      value: line.productId,
                      products: products,
                      onChanged: onProductChanged,
                    ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        WHStepperField(
          label: 'Qty',
          value: line.qty,
          onChanged: onQtyChanged,
          minValue: 0,
          allowManualInput: true,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 46,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Delete'),
            style: OutlinedButton.styleFrom(
              foregroundColor: WHColors.error2,
              backgroundColor: WHColors.surface,
              side: const BorderSide(color: WHColors.error3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductDropdown extends StatelessWidget {
  final int? value;
  final List<Map<String, dynamic>> products;
  final ValueChanged<int?> onChanged;

  const _ProductDropdown({
    required this.value,
    required this.products,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final productItems = products
        .map((product) {
          final id = _intValue(product, 'id');
          if (id == null) return null;
          return DropdownMenuItem<int>(
            value: id,
            child: Text(
              _stringValue(product, 'productName') ?? 'Product #$id',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: WHColors.grey1, fontSize: 16),
            ),
          );
        })
        .whereType<DropdownMenuItem<int>>()
        .toList();
    final selectedValue = productItems.any((item) => item.value == value)
        ? value
        : null;

    return DropdownButtonHideUnderline(
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: salesOrderFilledInputDecoration(14),
        child: DropdownButton<int>(
          isExpanded: true,
          value: selectedValue,
          hint: Text(
            products.isEmpty ? 'No products available' : 'Select Product',
            style: const TextStyle(color: WHColors.grey1, fontSize: 16),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: WHColors.grey3),
          items: productItems,
          onChanged: products.isEmpty ? null : onChanged,
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChanged;

  const _QtyStepper({required this.qty, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 144,
      height: 44,
      decoration: salesOrderFilledInputDecoration(14),
      child: Row(
        children: [
          _StepperButton(icon: Icons.remove, onTap: () => onChanged(qty - 1)),
          Container(
            width: 50,
            height: double.infinity,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: WHColors.surface,
              border: Border.symmetric(
                vertical: BorderSide(color: WHColors.grey3),
              ),
            ),
            child: Text(
              '$qty',
              style: const TextStyle(
                color: WHColors.grey1,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _StepperButton(icon: Icons.add, onTap: () => onChanged(qty + 1)),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: double.infinity,
          child: Icon(icon, color: WHColors.grey1, size: 22),
        ),
      ),
    );
  }
}

class _AddProductButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddProductButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add, size: 28),
        label: const Text('Product'),
        style: OutlinedButton.styleFrom(
          foregroundColor: WHColors.grey1,
          backgroundColor: WHColors.surface,
          side: const BorderSide(color: WHColors.grey3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _LoadingField extends StatelessWidget {
  const _LoadingField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      alignment: Alignment.center,
      decoration: salesOrderFilledInputDecoration(14),
      child: const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

int? _intValue(Map<String, dynamic> data, String key) {
  final value = data[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? _stringValue(Map<String, dynamic> data, String key) {
  final value = data[key];
  return value?.toString();
}
