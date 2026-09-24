import 'dart:io';
import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
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
    final clean = value.endsWith('.pdf') ? value.substring(0, value.length - 4) : value;
    return clean.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  Future<Directory> _resolveDownloadDirectory() async {
    if (Platform.isAndroid) {
      try {
        final externalDirs = await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        );
        if (externalDirs != null && externalDirs.isNotEmpty) {
          final dir = externalDirs.first;
          if (!await dir.exists()) await dir.create(recursive: true);
          return dir;
        }
      } catch (_) {}

      try {
        final publicDownload = Directory('/storage/emulated/0/Download/WareHaus');
        if (!await publicDownload.exists()) {
          await publicDownload.create(recursive: true);
        }
        return publicDownload;
      } catch (_) {}
    } else {
      try {
        final dir = await getDownloadsDirectory();
        if (dir != null) {
          if (!await dir.exists()) await dir.create(recursive: true);
          return dir;
        }
      } catch (_) {}
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    } catch (_) {}

    try {
      final dir = await getTemporaryDirectory();
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    } catch (_) {}

    return Directory.systemTemp;
  }
}
