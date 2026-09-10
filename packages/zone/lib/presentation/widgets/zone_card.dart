import 'package:core_ui/src/colors.dart';
import 'package:core_ui/src/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:zone/zone.dart';

class ZoneCard extends StatelessWidget {
  final Zone zone;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool canEdit;
  final bool canDelete;

  const ZoneCard({
    super.key,
    required this.zone,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.canEdit = false,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardChild = Container(
      decoration: BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: WHColors.grey.withOpacity(0.12)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: WHColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    zone.zoneCode,
                    style: WHTypography.caption.copyWith(
                      color: WHColors.surface,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone.zoneName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: WHTypography.heading1,
                      ),
                      Text(
                        '${zone.totalAisle} Aisles | ${zone.shelfPerAisle} Shelves',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: WHTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Jika tidak ada permission edit maupun delete, tampilkan card tanpa swipe
    if (!canEdit && !canDelete) {
      return RepaintBoundary(child: cardChild);
    }

    return RepaintBoundary(
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            if (canEdit)
              SlidableAction(
                onPressed: (context) {
                  Slidable.of(context)?.close();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onEdit?.call();
                  });
                },
                backgroundColor: WHColors.primary3,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
              ),
            if (canDelete)
              SlidableAction(
                onPressed: (context) {
                  Slidable.of(context)?.close();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onDelete?.call();
                  });
                },
                backgroundColor: WHColors.error2,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
          ],
        ),
        child: cardChild,
      ),
    );
  }
}
