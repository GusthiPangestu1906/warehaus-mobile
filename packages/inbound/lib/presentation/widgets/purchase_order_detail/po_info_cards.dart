import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class PoInfoCards extends StatelessWidget {
  const PoInfoCards({
    super.key,
    required this.etaLabel,
    required this.supplierName,
    required this.carrier,
    this.invoiceNumber,
  });

  final String etaLabel;
  final String supplierName;
  final String carrier;
  final String? invoiceNumber;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoCard(
          icon: Icons.event_available_outlined,
          label: 'ETA',
          value: etaLabel,
          backgroundColor: WHColors.primary3,
        ),
        if (invoiceNumber != null) ...[
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.description_outlined,
            label: 'Invoice Number',
            value: invoiceNumber!,
            backgroundColor: WHColors.secondary3,
          ),
        ],
        const SizedBox(height: 12),
        _InfoCard(
          icon: Icons.storefront_outlined,
          label: 'Supplier',
          value: supplierName,
          backgroundColor: WHColors.secondary3,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          icon: Icons.local_shipping_outlined,
          label: 'Carrier',
          value: carrier,
          backgroundColor: WHColors.grey3,
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
    required this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color backgroundColor;

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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: WHColors.surface, size: 22),
          ),
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
