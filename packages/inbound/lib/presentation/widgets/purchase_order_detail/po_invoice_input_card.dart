import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class PoInvoiceInputCard extends StatelessWidget {
  const PoInvoiceInputCard({
    super.key,
    required this.controller,
    required this.onSave,
  });

  final TextEditingController controller;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: WHColors.grey5),
      ),
      child: Column(
        children: [
          WHTextField(
            label: 'Invoice Number',
            hintText: 'e.g., INV-2026-001',
            controller: controller,
          ),
          const SizedBox(height: 12),
          WHButton(
            label: 'Save',
            icon: Icons.save_outlined,
            backgroundColor: WHColors.secondary3,
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}
