import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class SoDetailHeader extends StatelessWidget {
  const SoDetailHeader({
    super.key,
    required this.soNumber,
    required this.createdAt,
    required this.status,
    required this.showActions,
    required this.onDelete,
    required this.onEdit,
    this.canEdit = true,
    this.canDelete = true,
  });

  final String soNumber;
  final String createdAt;
  final String status;
  final bool showActions;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final bool canEdit;
  final bool canDelete;

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
          Text('Created at $createdAt', style: WHTypography.caption),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  soNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: WHTypography.title.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _StatusBadge(style: badgeStyle),
            ],
          ),
          if (showActions && (canDelete || canEdit)) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (canDelete) ...[
                  Expanded(
                    child: _HeaderOutlineButton(
                      label: 'Delete',
                      icon: Icons.delete_outline,
                      color: WHColors.error2,
                      onPressed: onDelete,
                    ),
                  ),
                  if (canEdit) const SizedBox(width: 6),
                ],
                if (canEdit)
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
        side: BorderSide(color: color.withValues(alpha: 0.65)),
        minimumSize: const Size(0, 42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: WHTypography.bodyText.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.style});

  final _StatusBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, color: style.textColor, size: 12),
          const SizedBox(width: 3),
          Text(
            style.label,
            style: WHTypography.caption.copyWith(
              color: style.textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadgeStyle {
  const _StatusBadgeStyle({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  factory _StatusBadgeStyle.fromStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'active':
        return const _StatusBadgeStyle(
          label: 'Active',
          icon: Icons.more_horiz,
          backgroundColor: WHColors.warning2,
          textColor: WHColors.warning1,
        );
      case 'completed':
      case 'complete':
      case 'success':
      case 'done':
        return const _StatusBadgeStyle(
          label: 'Completed',
          icon: Icons.check_circle,
          backgroundColor: WHColors.success2,
          textColor: WHColors.surface,
        );
      case 'pending':
      case 'queued':
      default:
        return const _StatusBadgeStyle(
          label: 'Queued',
          icon: Icons.access_time,
          backgroundColor: Color(0xFFEDEDED),
          textColor: WHColors.grey2,
        );
    }
  }
}
