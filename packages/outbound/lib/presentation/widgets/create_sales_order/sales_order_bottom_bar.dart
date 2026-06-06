import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class SalesOrderBottomBar extends StatelessWidget {
  final String label;
  final bool showCheckIcon;
  final bool isLoading;
  final VoidCallback? onPressed;

  const SalesOrderBottomBar({
    super.key,
    required this.label,
    required this.showCheckIcon,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 12),
      decoration: const BoxDecoration(
        color: WHColors.surface,
        border: Border(top: BorderSide(color: WHColors.grey4, width: 0.4)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 42,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: showCheckIcon
                ? const Icon(Icons.check_circle_outline, size: 18)
                : const SizedBox.shrink(),
            label: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: WHColors.surface,
                    ),
                  )
                : Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: WHColors.secondary3,
              foregroundColor: WHColors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Colors.black, width: 1),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
