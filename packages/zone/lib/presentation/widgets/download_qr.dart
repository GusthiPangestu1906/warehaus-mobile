import 'dart:io';

import 'package:core_services/api/api_client.dart';
import 'package:core_ui/core_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zone/presentation/widgets/format_dialog_qr.dart';

/// Small service that downloads an image from [url] to a temporary file
/// and saves it to the gallery using `Gal`.
class QRDownloader {
  final Dio _dio;

  QRDownloader([Dio? dio]) : _dio = dio ?? ApiClient().dio;

  /// Downloads the image at [url] and saves it to the gallery.
  /// Throws on any failure.
  Future<void> downloadAndSave(String url) async {
    // Backward-compatible simple download (keeps previous behaviour)
    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png';
    await _dio.download(url, filePath);
    await Gal.putImage(filePath);
    // Optionally remove the temp file
    try {
      final f = File(filePath);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  /// Sends a GET request to [url], expects raw bytes response and saves the file 
  /// to external Download/WareHaus folder on Android.
  /// The backend ignores the [option] and always returns a zip file containing the QR codes.
  /// [code] is used as the filename (e.g. 'LZ-1-1' -> 'LZ-1-1.zip').
  Future<String> downloadWithOption(
    String url,
    String option,
    String code,
  ) async {
    // Request bytes from backend (use GET because no option needed for QR zip)
    final response = await _dio.get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    final bytes = response.data;
    if (bytes == null) throw Exception('Empty response from server');

    // The backend always generates a zip
    final ext = 'zip';
    final fileName = '$code.$ext';

    // Target directory on Android
    final targetDir = Directory('/storage/emulated/0/Download/WareHaus');
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final file = File('${targetDir.path}/$fileName');
    await file.writeAsBytes(bytes);

    return file.path;
  }
}

/// Button widget that handles download flow and shows snackbars.
class DownloadQRButton extends StatefulWidget {
  const DownloadQRButton({super.key, required this.url, required this.code});

  final String url;
  final String code;

  @override
  State<DownloadQRButton> createState() => _DownloadQRButtonState();
}

class _DownloadQRButtonState extends State<DownloadQRButton> {
  bool _loading = false;
  final QRDownloader _downloader = QRDownloader();

  Future<void> _handleDownload() async {
    if (_loading) return;

    // Debug hint: show a short snackbar so we can verify this code runs
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening custom format dialog...'),
        duration: Duration(milliseconds: 700),
      ),
    );

    // Ask user which format they want (custom bottom sheet)
    final option = await FormatDialogQr.show(context);

    if (option == null) return;

    setState(() => _loading = true);
    try {
      final savedPath = await _downloader.downloadWithOption(
        widget.url,
        option,
        widget.code,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Berhasil diunduh: $savedPath')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengunduh: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _loading ? null : _handleDownload,
      icon: _loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: WHColors.surface,
              ),
            )
          : const Icon(Icons.download_outlined, color: WHColors.surface),
      label: Text(
        _loading ? 'Mengunduh...' : 'Download QR',
        style: const TextStyle(color: WHColors.surface),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        backgroundColor: WHColors.primary1,
      ),
    );
  }
}

// NOTE: Make sure to request storage/photo permissions on Android/iOS as needed.
