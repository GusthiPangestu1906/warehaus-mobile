import 'package:zone/domain/repositories/zone_repository.dart';

class DownloadShelfQr {
  final ZoneRepository repository;
  DownloadShelfQr(this.repository);

  Future<List<int>> call({
    required int shelfId,
    required String format,
  }) {
    return repository.downloadShelfQr(
      shelfId: shelfId,
      format: format,
    );
  }
}
