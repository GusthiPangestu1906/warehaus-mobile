// packages/core_ui/lib/src/components/wh_outlined_button.dart
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class WHOutlinedButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? borderColor;

  const WHOutlinedButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor = borderColor ?? WHColors.primary3;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: WHColors.surface,
        foregroundColor: defaultColor,
        side: BorderSide(color: defaultColor, width: 1.5),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: defaultColor),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: defaultColor,
            ),
          ),
        ],
      ),
    );
  }
}
