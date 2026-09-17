import 'package:auth/presentation/components/icon_hero.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class SettingHero extends StatelessWidget {
  final String fullName;
  final String email;
  final String status;

  const SettingHero({
    super.key,
    required this.fullName,
    required this.email,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        spacing: 16,
        children: [
          // icon hero
          const IconHero(),

          // fullName and email
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // full name
              Text(fullName, style: WHTypography.heading1),
              // email
              Text(email, style: WHTypography.bodyText),
            ],
          ),

          // status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'active'
                      ? WHColors.success.withValues(alpha: 0.1)
                      : WHColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(status, style: WHTypography.bodyText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
