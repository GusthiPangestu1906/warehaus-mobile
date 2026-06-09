import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class SoInfoCards extends StatelessWidget {
  const SoInfoCards({
    super.key,
    required this.slaLabel,
    required this.customerName,
    required this.companyName,
    required this.courier,
    required this.address,
    required this.province,
    required this.city,
    required this.postalCode,
    this.trackingNumber,
  });

  final String slaLabel;
  final String customerName;
  final String companyName;
  final String courier;
  final String address;
  final String province;
  final String city;
  final String postalCode;
  final String? trackingNumber;

  @override
  Widget build(BuildContext context) {
    final hasTracking = trackingNumber != null && trackingNumber!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.event_available_outlined,
                label: 'SLA',
                value: slaLabel,
                backgroundColor: WHColors.primary3,
              ),
            ),
            if (hasTracking) ...[
              const SizedBox(width: 6),
              Expanded(
                child: _InfoCard(
                  icon: Icons.tag,
                  label: 'Tracking Number',
                  value: trackingNumber!,
                  backgroundColor: const Color(0xFF073B72),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Container(
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
                children: [
                  Expanded(
                    child: _InlineInfo(
                      icon: Icons.person,
                      label: customerName,
                      value: companyName,
                      backgroundColor: WHColors.secondary3,
                    ),
                  ),
                  Expanded(
                    child: _InlineInfo(
                      icon: Icons.local_shipping_outlined,
                      label: 'Courier',
                      value: courier,
                      backgroundColor: WHColors.grey5,
                      iconColor: WHColors.surface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _InlineInfo(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: address,
                backgroundColor: WHColors.success2,
                maxValueLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _RegionPill(label: 'Province', value: province),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _RegionPill(label: 'City', value: city),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _RegionPill(label: 'Postal Code', value: postalCode),
                  ),
                ],
              ),
            ],
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
      child: _InlineInfo(
        icon: icon,
        label: label,
        value: value,
        backgroundColor: backgroundColor,
        dense: true,
      ),
    );
  }
}

class _InlineInfo extends StatelessWidget {
  const _InlineInfo({
    required this.icon,
    required this.label,
    required this.value,
    required this.backgroundColor,
    this.iconColor = WHColors.surface,
    this.maxValueLines = 2,
    this.dense = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color backgroundColor;
  final Color iconColor;
  final int maxValueLines;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: iconColor, size: dense ? 22 : 24),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: dense ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: dense
                    ? WHTypography.caption
                    : WHTypography.bodyText.copyWith(
                        fontSize: 14,
                        color: WHColors.grey2,
                      ),
              ),
              Text(
                value,
                maxLines: maxValueLines,
                overflow: TextOverflow.ellipsis,
                style: WHTypography.bodyText.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RegionPill extends StatelessWidget {
  const _RegionPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 51,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFCFE6FF),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label\n', style: WHTypography.caption),
            TextSpan(
              text: value,
              style: WHTypography.bodyText.copyWith(fontSize: 14),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
