import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:outbound/presentation/widgets/create_sales_order/sales_order_form_styles.dart';

class SalesOrderFieldCard extends StatelessWidget {
  final String label;
  final String? optionalLabel;
  final bool isNested;
  final Widget child;

  const SalesOrderFieldCard({
    super.key,
    required this.label,
    required this.child,
    this.optionalLabel,
    this.isNested = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isNested ? 8 : 12),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: salesOrderPlainCardDecoration(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              if (optionalLabel != null)
                Text(
                  optionalLabel!,
                  style: const TextStyle(
                    color: WHColors.grey2,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class SalesOrderTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const SalesOrderTextInput({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    return WHTextField(
      label: label,
      hintText: hint,
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
    );
  }
}

class SalesOrderNoteInput extends StatelessWidget {
  final TextEditingController controller;
  final int count;

  const SalesOrderNoteInput({
    super.key,
    required this.controller,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return WHDescriptionField(
      label: '',
      hintText: 'Text here...',
      controller: controller,
      maxLength: 150,
      isOptional: true,
      maxLines: 4,
    );
  }
}

class SalesOrderSelectField<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final String emptyHint;
  final bool isLoading;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const SalesOrderSelectField({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.emptyHint = 'No data available',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasItems = items.isNotEmpty;

    // Convert DropdownMenuItem to WHDropdownItem
    final whItems = items
        .map(
          (item) => WHDropdownItem<T>(
            value: item.value as T,
            label: item.child.toString(),
          ),
        )
        .toList();

    // Find selected value that exists in items
    T? selectedValue;
    if (value != null) {
      for (final item in items) {
        if (item.value == value) {
          selectedValue = value;
          break;
        }
      }
    }

    return WHDropdownField<T>(
      label: '',
      hintText: isLoading
          ? 'Loading...'
          : hasItems
          ? hint
          : emptyHint,
      selectedValue: selectedValue,
      items: whItems,
      onChanged: isLoading || !hasItems ? null : onChanged,
    );
  }
}

String? Function(String?) requiredSalesOrderField(String label) {
  return (value) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  };
}
