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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      decoration: const BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        spacing: 16,
        children: [
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
                  color: status == 'Active'
                      ? WHColors.success3
                      : WHColors.error3,
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
