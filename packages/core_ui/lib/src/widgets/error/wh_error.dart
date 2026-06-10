import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class WHError extends StatelessWidget {
  const WHError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: WHColors.error4,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: WHColors.error3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 16, color: WHColors.error2),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: WHTypography.caption.copyWith(
                color: WHColors.error2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
