import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../colors.dart';
import '../typography.dart';
import '../widgets/wh_snackbar.dart';

class OrderLabelItem {
  final String sku;
  final String productName;
  final String quantity;

  const OrderLabelItem({
    required this.sku,
    required this.productName,
    required this.quantity,
  });
}

class OrderLabelData {
  final String documentType; // 'Sales Order' or 'Purchase Order'
  final String status; // 'Completed'
  final String orderNumber; // 'SO-240926-DONE'
  final List<MapEntry<String, String>> leftDetails;
  final List<MapEntry<String, String>> rightDetails;
  final List<OrderLabelItem> items;

  const OrderLabelData({
    required this.documentType,
    required this.status,
    required this.orderNumber,
    required this.leftDetails,
    required this.rightDetails,
    required this.items,
  });
}

class OrderLabelPdfService {
  /// Menghasilkan berkas PDF label dengan tata letak persis seperti versi cetak web
  static Future<Uint8List> generateLabelPdf(OrderLabelData data) async {
    final pdf = pw.Document();

    pw.Font font;
    pw.Font fontBold;
    try {
      font = await PdfGoogleFonts.interRegular().timeout(const Duration(seconds: 3));
      fontBold = await PdfGoogleFonts.interBold().timeout(const Duration(seconds: 3));
    } catch (_) {
      font = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36), // ~12mm padding
        build: (pw.Context context) {
          return [
            // 1. Header (WareHaus & Document Type)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'WareHaus',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  '${data.documentType} · ${data.status}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Container(
              height: 1.5,
              color: PdfColors.black,
            ),
            pw.SizedBox(height: 16),

            // 2. Order Title (Nomor PO / SO)
            pw.Text(
              data.orderNumber,
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 14),

            // 3. 2-Column Metadata Grid
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Kolom Kiri
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: data.leftDetails.map((detail) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 10, right: 12),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              detail.key,
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 9.5,
                                color: PdfColors.grey800,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              detail.value.isNotEmpty ? detail.value : '—',
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 10.5,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Kolom Kanan
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: data.rightDetails.map((detail) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 10, left: 12),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              detail.key,
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 9.5,
                                color: PdfColors.grey800,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              detail.value.isNotEmpty ? detail.value : '—',
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 10.5,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),

            // 4. Products Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 1),
              columnWidths: {
                0: const pw.FixedColumnWidth(100),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FixedColumnWidth(90),
              },
              children: [
                // Header Table
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: pw.Text(
                        'SKU',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: pw.Text(
                        'Product Name',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: pw.Text(
                        'QTY',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // Isi Baris Produk
                ...data.items.map((item) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: pw.Text(
                          item.sku,
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: pw.Text(
                          item.productName,
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: pw.Text(
                          item.quantity,
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Membuka dialog print / preview PDF bawaan OS perangkat (bisa cetak printer / Simpan sebagai PDF)
  static Future<void> printLabel({
    required String name,
    required OrderLabelData data,
  }) async {
    final pdfBytes = await generateLabelPdf(data);
    final cleanName = name.endsWith('.pdf') ? name : '$name.pdf';
    await Printing.layoutPdf(
      name: cleanName,
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  /// Membuka dialog share / simpan PDF ke aplikasi lain atau Google Drive / Files
  static Future<void> shareLabelPdf({
    required String fileName,
    required OrderLabelData data,
  }) async {
    final pdfBytes = await generateLabelPdf(data);
    final cleanName = fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';
    final sanitizedName = cleanName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    await Printing.sharePdf(bytes: pdfBytes, filename: sanitizedName);
  }

  /// Menyimpan file PDF langsung ke folder Download perangkat
  static Future<String> saveLabelToDownloads({
    required String fileName,
    required OrderLabelData data,
  }) async {
    final pdfBytes = await generateLabelPdf(data);
    return savePdfBytes(pdfBytes: pdfBytes, fileName: fileName);
  }

  /// Menyimpan Uint8List byte PDF secara aman ke penyimpanan perangkat
  static Future<String> savePdfBytes({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    final cleanName = fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';
    final sanitizedName = cleanName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

    Directory? targetDir;

    // 1. Coba external storage downloads di Android (aman tanpa permission di Android 10-15+)
    if (Platform.isAndroid) {
      try {
        final externalDirs = await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        );
        if (externalDirs != null && externalDirs.isNotEmpty) {
          targetDir = externalDirs.first;
          if (!await targetDir.exists()) {
            await targetDir.create(recursive: true);
          }
        }
      } catch (e) {
        debugPrint('[OrderLabelPdfService] getExternalStorageDirectories error: $e');
      }

      // Coba folder Download publik jika ada izin
      if (targetDir == null) {
        try {
          final publicDownload = Directory('/storage/emulated/0/Download/WareHaus');
          if (!await publicDownload.exists()) {
            await publicDownload.create(recursive: true);
          }
          targetDir = publicDownload;
        } catch (_) {
          // Lewati jika Scoped Storage memblokir penulisan langsung
        }
      }
    } else {
      try {
        targetDir = await getDownloadsDirectory();
        if (targetDir != null && !await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
      } catch (e) {
        debugPrint('[OrderLabelPdfService] getDownloadsDirectory error: $e');
      }
    }

    // 2. Fallback ke Application Documents Directory
    if (targetDir == null) {
      try {
        targetDir = await getApplicationDocumentsDirectory();
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
      } catch (e) {
        debugPrint('[OrderLabelPdfService] getApplicationDocumentsDirectory error: $e');
      }
    }

    // 3. Fallback ke Temporary Directory
    if (targetDir == null) {
      try {
        targetDir = await getTemporaryDirectory();
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
      } catch (e) {
        debugPrint('[OrderLabelPdfService] getTemporaryDirectory error: $e');
      }
    }

    targetDir ??= Directory.systemTemp;

    final file = File('${targetDir.path}/$sanitizedName');
    await file.writeAsBytes(pdfBytes, flush: true);
    return file.path;
  }

  /// Menampilkan Action Sheet / Modal Bottom Sheet pilihan Cetak, Bagikan, dan Simpan Label
  static Future<void> showLabelActionModal({
    required BuildContext context,
    required String orderNumber,
    required OrderLabelData data,
  }) async {
    final fileName = '$orderNumber-label.pdf';

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D7D7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Label ${data.documentType}',
                  style: WHTypography.heading2.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nomor: ${data.orderNumber}',
                  style: WHTypography.caption.copyWith(color: WHColors.textSecondary),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFECECEC)),
                const SizedBox(height: 8),

                // Option 1: Print / Preview
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: WHColors.primary3.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.print_outlined, color: WHColors.primary3),
                  ),
                  title: Text('Cetak Label / Print Preview', style: WHTypography.bodyText.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text('Buka pratinjau cetak & simpan sebagai PDF bawaan', style: WHTypography.caption),
                  onTap: () async {
                    Navigator.of(modalContext).pop();
                    try {
                      await printLabel(name: fileName, data: data);
                    } catch (e) {
                      if (!context.mounted) return;
                      debugPrint('[OrderLabelPdfService] printLabel error: $e');
                      WHSnackBar.showError(context, 'Gagal membuka print dialog: $e');
                    }
                  },
                ),

                // Option 2: Download & Simpan
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: WHColors.secondary3.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.download_outlined, color: WHColors.secondary3),
                  ),
                  title: Text('Unduh / Simpan PDF', style: WHTypography.bodyText.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text('Simpan berkas PDF label ke penyimpanan HP', style: WHTypography.caption),
                  onTap: () async {
                    Navigator.of(modalContext).pop();
                    try {
                      final savedPath = await saveLabelToDownloads(fileName: fileName, data: data);
                      if (!context.mounted) return;
                      WHSnackBar.showSuccess(context, 'Label berhasil disimpan:\n$savedPath');
                    } catch (e) {
                      if (!context.mounted) return;
                      debugPrint('[OrderLabelPdfService] saveLabelToDownloads error: $e');
                      WHSnackBar.showError(context, 'Gagal menyimpan PDF label: $e');
                    }
                  },
                ),

                // Option 3: Share PDF
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: WHColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.share_outlined, color: WHColors.warning),
                  ),
                  title: Text('Bagikan PDF (Share)', style: WHTypography.bodyText.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text('Kirim berkas PDF ke WhatsApp, Email, atau Drive', style: WHTypography.caption),
                  onTap: () async {
                    Navigator.of(modalContext).pop();
                    try {
                      await shareLabelPdf(fileName: fileName, data: data);
                    } catch (e) {
                      if (!context.mounted) return;
                      debugPrint('[OrderLabelPdfService] shareLabelPdf error: $e');
                      WHSnackBar.showError(context, 'Gagal membagikan PDF label: $e');
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
