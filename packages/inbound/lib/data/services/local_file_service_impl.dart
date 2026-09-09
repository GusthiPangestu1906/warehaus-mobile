// data/services/local_file_service_impl.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:core_services/core_services.dart';
import '../../domain/services/local_file_service.dart';

class LocalFileServiceImpl implements LocalFileService {
  @override
  Future<Either<Failure, String>> savePdf(
    List<int> bytes,
    String fileName,
  ) async {
    try {
      final sanitizedName = _sanitizeFileName(fileName);
      final targetDir = await _resolveDownloadDirectory();

      final file = File('${targetDir.path}/$sanitizedName.pdf');
      await file.writeAsBytes(bytes, flush: true);

      return Right(file.path);
    } catch (e) {
      return Left(CacheFailure('Gagal menyimpan file: $e'));
    }
  }

  String _sanitizeFileName(String value) {
    return value.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  Future<Directory> _resolveDownloadDirectory() async {
    final downloadDir = Directory('/storage/emulated/0/Download/WareHaus');
    try {
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
    } catch (_) {
      final fallbackDir = Directory('${Directory.systemTemp.path}/WareHaus');
      if (!await fallbackDir.exists()) {
        await fallbackDir.create(recursive: true);
      }
      return fallbackDir;
    }
  }
}
