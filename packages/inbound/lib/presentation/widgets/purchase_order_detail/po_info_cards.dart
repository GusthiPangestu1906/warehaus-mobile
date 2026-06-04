import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class PoInfoCards extends StatelessWidget {
  const PoInfoCards({super.key, required this.etaLabel, this.invoiceNumber});

  final String etaLabel;
  final String? invoiceNumber;

  @override
  Widget build(BuildContext context) {
    if (invoiceNumber == null) {
      return _InfoCard(
        icon: Icons.event_available_outlined,
        label: 'ETA',
        value: etaLabel,
      );
    }

    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            icon: Icons.event_available_outlined,
            label: 'ETA',
            value: etaLabel,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            icon: Icons.receipt_long_outlined,
            label: 'Invoice Number',
            value: invoiceNumber!,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: WHColors.grey5),
      ),
      child: Row(
        children: [
          Icon(icon, color: WHColors.primary3, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: WHTypography.caption),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: WHTypography.bodyText.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
