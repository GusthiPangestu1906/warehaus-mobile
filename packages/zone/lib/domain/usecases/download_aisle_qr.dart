import 'package:zone/domain/repositories/zone_repository.dart';

class DownloadAisleQr {
  final ZoneRepository repository;
  DownloadAisleQr(this.repository);

  Future<List<int>> call({
    required int zoneId,
    required int aisleNumber,
    required String format,
  }) {
    return repository.downloadAisleQr(
      zoneId: zoneId,
      aisleNumber: aisleNumber,
      format: format,
    );
  }
}
