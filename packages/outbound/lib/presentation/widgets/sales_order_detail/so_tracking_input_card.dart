import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class SoTrackingInputCard extends StatelessWidget {
  const SoTrackingInputCard({
    super.key,
    required this.controller,
    required this.isEditing,
    required this.onStart,
    required this.onSave,
  });

  final TextEditingController controller;
  final bool isEditing;
  final VoidCallback onStart;
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF073B72),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.tag, color: WHColors.surface, size: 24),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: isEditing
                ? _TrackingForm(controller: controller, onSave: onSave)
                : SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: onStart,
                      icon: const Icon(Icons.add, size: 27),
                      label: const Text('Tracking Number'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WHColors.secondary3,
                        foregroundColor: WHColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Colors.black),
                        ),
                        textStyle: WHTypography.bodyText.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TrackingForm extends StatelessWidget {
  const _TrackingForm({required this.controller, required this.onSave});

  final TextEditingController controller;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tracking Number',
          style: WHTypography.bodyText.copyWith(
            fontSize: 15,
            color: WHColors.grey1,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 44,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'e.g., Electronic',
              hintStyle: TextStyle(
                color: WHColors.grey3.withValues(alpha: 0.7),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              filled: true,
              fillColor: const Color(0xFFF0F0F0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: WHColors.grey2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          height: 28,
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: WHColors.secondary3,
              foregroundColor: WHColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.black),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}
