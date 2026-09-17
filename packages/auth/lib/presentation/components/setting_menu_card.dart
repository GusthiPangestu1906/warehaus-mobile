import 'package:flutter/material.dart';

class SettingMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool hasChevron;
  final bool isDanger;
  final VoidCallback? onTap;

  const SettingMenuCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.hasChevron = false,
    this.isDanger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Gaya khusus untuk tombol Keluar (Danger)
    if (isDanger) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEB), // Merah muda terang
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFB71C1C)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFB71C1C),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Gaya standar untuk List Item
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE), // Biru muda terang
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF1565C0)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: subtitle != null
                          ? Colors.grey.shade600
                          : Colors.black87,
                      fontSize: subtitle != null ? 12 : 16,
                      fontWeight: subtitle != null
                          ? FontWeight.w500
                          : FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hasChevron)
              const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
