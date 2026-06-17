import 'dart:io';

import 'package:core_services/api/api_client.dart';
import 'package:core_ui/core_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zone/domain/usecases/download_aisle_qr.dart';
import 'package:zone/domain/usecases/download_shelf_qr.dart';
import 'package:zone/presentation/widgets/format_dialog_qr.dart';

/// Small service that orchestrates downloading of QR codes.
/// It delegates network calls to UseCases and handles platform/file-saving concerns.
class QRDownloader {
  final DownloadAisleQr _downloadAisleQr;
  final DownloadShelfQr _downloadShelfQr;

  QRDownloader()
      : _downloadAisleQr = GetIt.I<DownloadAisleQr>(),
        _downloadShelfQr = GetIt.I<DownloadShelfQr>();

  /// Downloads the image at [url] and saves it to the gallery.
  Future<void> downloadAndSave(String url) async {
    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png';
    await ApiClient().dio.download(url, filePath);
    await Gal.putImage(filePath);
    try {
      final f = File(filePath);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  /// Downloads aisle QRs (PNG/PDF) using Clean Architecture.
  Future<String> downloadAisle({
    required int zoneId,
    required int aisleNumber,
    required String format,
    required String code,
  }) async {
    final bytes = await _downloadAisleQr(
      zoneId: zoneId,
      aisleNumber: aisleNumber,
      format: format,
    );
    return await _saveBytes(bytes, format, code);
  }

  /// Downloads shelf QR (PNG/PDF) using Clean Architecture.
  Future<String> downloadShelf({
    required int shelfId,
    required String format,
    required String code,
  }) async {
    final bytes = await _downloadShelfQr(
      shelfId: shelfId,
      format: format,
    );
    return await _saveBytes(bytes, format, code);
  }

  /// Backward-compatible legacy download helper for raw URLs.
  Future<String> downloadLegacy({
    required String url,
    required String option,
    required String code,
  }) async {
    var finalUrl = url;
    if (option.toLowerCase() == 'pdf') {
      if (finalUrl.endsWith('download')) {
        finalUrl = '$finalUrl-pdf';
      } else {
        finalUrl = '$finalUrl/download-pdf';
      }
    }
    final response = await ApiClient().dio.get<List<int>>(
      finalUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    return await _saveBytes(response.data ?? [], option, code);
  }

  Future<String> _saveBytes(List<int> bytes, String option, String code) async {
    final ext = option.toLowerCase() == 'pdf' ? 'pdf' : 'zip';
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
  const DownloadQRButton({
    super.key,
    required this.downloadFn,
    required this.code,
  });

  final Future<String> Function(String format) downloadFn;
  final String code;

  @override
  State<DownloadQRButton> createState() => _DownloadQRButtonState();
}

class _DownloadQRButtonState extends State<DownloadQRButton> {
  bool _loading = false;

  Future<void> _handleDownload() async {
    if (_loading) return;

    // Ask user which format they want (custom bottom sheet)
    final option = await FormatDialogQr.show(context);

    if (option == null) return;

    setState(() => _loading = true);
    try {
      final savedPath = await widget.downloadFn(option);
      if (!mounted) return;
      WHSnackBar.showSuccess(context, 'Berhasil diunduh: $savedPath');
    } catch (e) {
      if (!mounted) return;
      WHSnackBar.showError(context, 'Gagal mengunduh: $e');
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
