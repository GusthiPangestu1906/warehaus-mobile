import 'package:flutter/material.dart';

import '../../colors.dart';

class WHSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Tombol mati (disabled) jika null
  final IconData? icon;

  const WHSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon = Icons.check_circle,
  });

  @override
  Widget build(BuildContext context) {
    // Mengecek apakah status tombol aktif atau mati (disabled)
    final bool isDisabled = onPressed == null;

    // Menentukan warna latar belakang tombol berdasarkan status
    final Color backgroundColor = isDisabled
        ? WHColors.grey4
        : WHColors.primary3;

    // Menentukan warna konten (teks dan ikon) berdasarkan status
    final Color contentColor = isDisabled
        ? WHColors.grey5
        : WHColors.surface; // Abu-abu pudar konten

    return Container(
      height: 56, // Tinggi tombol
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(32), // Sudut sangat membulat
      ),
      child: InkWell(
        onTap: onPressed, // Pasang aksi tekan
        borderRadius: BorderRadius.circular(
          32,
        ), // Agar ripple effect ikut membulat
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Pusatkan konten secara horizontal
            mainAxisSize: MainAxisSize.min, // Isi konten secukupnya
            children: [
              Text(
                text,
                style: TextStyle(
                  color: contentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8), // Jarak antara teks dan ikon
                Icon(icon, color: contentColor, size: 25),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
