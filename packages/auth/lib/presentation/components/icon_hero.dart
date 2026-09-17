import 'package:flutter/material.dart';
import 'package:core_ui/core_ui.dart';

class IconHero extends StatelessWidget {
  const IconHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/icon/app_icon.png', width: 48, height: 48),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Ware',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: WHColors.primary,
                  ),
                ),
                Text(
                  'Haus',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: WHColors.secondary,
                  ),
                ),
              ],
            ),
            Text('Warehouse Management System', style: WHTypography.caption),
          ],
        ),
      ],
    );
  }
}
