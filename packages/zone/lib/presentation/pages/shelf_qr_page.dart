import 'package:core_services/api/api_client.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:zone/presentation/widgets/download_qr.dart';

class ShelfQrPage extends StatelessWidget {
  const ShelfQrPage({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    // Construct a reasonable default URL based on ApiClient baseUrl.
    final base = ApiClient().dio.options.baseUrl ?? '';
    // Absolute URL for Image.network
    final apiBase = base.endsWith('/') ? '${base}api' : '$base/api';
    final imageUrl = '$apiBase/Zones/qr/$code';
    // Relative URL for DownloadQRButton so the interceptor prepends /api/
    final downloadUrl = '/Zones/qr/$code';

    return Scaffold(
      appBar: WHAppbar(title: 'QR $code'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Preview - try loading from network; if fails, show icon
                    SizedBox(
                      height: 220,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, e, st) => Center(
                            child: Icon(
                              Icons.qr_code_2_rounded,
                              size: 96,
                              color: WHColors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      code,
                      style: WHTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Use existing DownloadQRButton to handle download flow
            DownloadQRButton(url: downloadUrl, code: code),
          ],
        ),
      ),
    );
  }
}
