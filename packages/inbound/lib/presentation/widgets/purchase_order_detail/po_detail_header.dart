import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PoDetailHeader extends StatelessWidget {
  const PoDetailHeader({
    super.key,
    required this.poNumber,
    required this.status,
    required this.supplierName,
    required this.carrier,
    required this.showActions,
    required this.onDelete,
    required this.onEdit,
  });

  final String poNumber;
  final String status;
  final String supplierName;
  final String carrier;
  final bool showActions;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final badgeStyle = _StatusBadgeStyle.fromStatus(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: WHColors.grey5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Created At ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                      style: WHTypography.caption,
                    ),
                    const SizedBox(height: 4),
                    Text(poNumber, style: WHTypography.heading1),
                  ],
                ),
              ),
              _StatusBadge(style: badgeStyle),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _HeaderOutlineButton(
                    label: 'Delete',
                    icon: Icons.delete_outline,
                    color: WHColors.error2,
                    onPressed: onDelete,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HeaderOutlineButton(
                    label: 'Edit',
                    icon: Icons.edit_outlined,
                    color: WHColors.primary3,
                    onPressed: onEdit,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderOutlineButton extends StatelessWidget {
  const _HeaderOutlineButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.5),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: WHTypography.bodyText.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoText extends StatelessWidget {
  const _InfoText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: WHTypography.caption),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: WHTypography.bodyText.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.style});

  final _StatusBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        style.label,
        style: WHTypography.caption.copyWith(
          color: style.textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusBadgeStyle {
  const _StatusBadgeStyle({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  factory _StatusBadgeStyle.fromStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'active':
        return const _StatusBadgeStyle(
          label: 'Active',
          backgroundColor: WHColors.warning4,
          textColor: WHColors.warning1,
        );
      case 'success':
      case 'completed':
        return const _StatusBadgeStyle(
          label: 'Completed',
          backgroundColor: WHColors.success4,
          textColor: WHColors.success1,
        );
      case 'pending':
      case 'queued':
      default:
        return const _StatusBadgeStyle(
          label: 'Queued',
          backgroundColor: WHColors.grey5,
          textColor: WHColors.grey2,
        );
    }
  }
}
