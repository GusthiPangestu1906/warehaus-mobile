import 'package:core_services/api/api_client.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:zone/presentation/widgets/download_qr.dart';

class ShelfQrPage extends StatefulWidget {
  const ShelfQrPage({super.key, required this.code});

  final String code;

  @override
  State<ShelfQrPage> createState() => _ShelfQrPageState();
}

class _ShelfQrPageState extends State<ShelfQrPage> {
  late final ApiClient _apiClient;
  late final QRDownloader _qrDownloader;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _apiClient = GetIt.I<ApiClient>();
    _qrDownloader = GetIt.I<QRDownloader>();
    _loadAuthHeaders();
  }

  Future<void> _loadAuthHeaders() async {
    final token = await _apiClient.tokenStorage.getAccessToken();
    if (mounted) {
      setState(() {
        _authToken = token;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = _apiClient.dio.options.baseUrl;
    final apiBase = base.endsWith('/') ? '${base}api' : '$base/api';
    final imageUrl = '$apiBase/Zones/qr/${widget.code}';
    final downloadUrl = '/Zones/qr/${widget.code}';

    return Scaffold(
      appBar: WHAppbar(title: 'QR ${widget.code}'),
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
                    SizedBox(
                      height: 220,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _authToken == null
                            ? const Center(child: CircularProgressIndicator())
                            : Image.network(
                                imageUrl,
                                // Menyuntikkan Bearer Token agar Image.network diizinkan oleh backend API
                                headers: {
                                  'Authorization': 'Bearer $_authToken',
                                  'ngrok-skip-browser-warning': 'true',
                                },
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
                      widget.code,
                      style: WHTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            DownloadQRButton(
              downloadFn: (format) => _qrDownloader.downloadLegacy(
                url: downloadUrl,
                option: format,
                code: widget.code,
              ),
              code: widget.code,
            ),
          ],
        ),
      ),
    );
  }
}
