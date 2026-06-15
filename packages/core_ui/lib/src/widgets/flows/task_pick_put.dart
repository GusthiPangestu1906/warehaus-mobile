import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class TaskPickPutCard extends StatelessWidget {
  const TaskPickPutCard({
    super.key,
    required this.location,
    required this.qty,
    required this.uom,
    this.isCompleted = false,
    this.onScan,
  });

  final String location;
  final int qty;
  final String uom;
  final bool isCompleted;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return _CompletedLocationCard(location: location);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 22, 12, 24),
      decoration: BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF7B7486), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: WHColors.secondary4,
                size: 24,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: WHTypography.heading1.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Required Item',
            style: WHTypography.bodyText.copyWith(
              color: WHColors.textSecondary,
              fontSize: 16,
            ),
          ),
          Text(
            '$qty $uom',
            style: WHTypography.bodyText.copyWith(
              color: WHColors.primary1,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Verify QR Shelf',
            style: WHTypography.bodyText.copyWith(
              color: WHColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          WHButton(
            label: 'Scan',
            icon: Icons.qr_code_scanner,
            backgroundColor: WHColors.primary1,
            onPressed: onScan,
          ),
        ],
      ),
    );
  }
}

class _CompletedLocationCard extends StatelessWidget {
  const _CompletedLocationCard({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: WHColors.success4,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WHColors.success2, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: WHColors.success1,
                size: 22,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  style: WHTypography.heading2.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const _VerifiedBadge(),
        ],
      ),
    );
  }
}

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) => const _VerifiedBadge();
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: WHColors.success2,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Verified',
            style: WHTypography.caption.copyWith(
              color: WHColors.surface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.check_circle, color: WHColors.surface, size: 12),
        ],
      ),
    );
  }
}
