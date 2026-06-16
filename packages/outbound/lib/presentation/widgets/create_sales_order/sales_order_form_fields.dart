import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const SalesOrderTextInput({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.black, fontSize: 13),
      decoration: salesOrderInputDecoration(hint),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFormField(
          controller: controller,
          minLines: 4,
          maxLines: 4,
          maxLength: 150,
          inputFormatters: [LengthLimitingTextInputFormatter(150)],
          style: const TextStyle(color: Colors.black, fontSize: 13),
          decoration: salesOrderInputDecoration('Text here...').copyWith(
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$count/150',
          style: const TextStyle(color: WHColors.grey2, fontSize: 10),
        ),
      ],
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
    final selectedValue = items.any((item) => item.value == value)
        ? value
        : null;
    return DropdownButtonFormField<T>(
      key: ValueKey('${T.toString()}-$selectedValue-${items.length}'),
      initialValue: hasItems ? selectedValue : null,
      isExpanded: true,
      decoration: salesOrderInputDecoration(
        isLoading
            ? 'Loading...'
            : hasItems
            ? hint
            : emptyHint,
      ),
      icon: const Icon(Icons.keyboard_arrow_down, size: 18),
      style: const TextStyle(color: Colors.black, fontSize: 13),
      items: items,
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
