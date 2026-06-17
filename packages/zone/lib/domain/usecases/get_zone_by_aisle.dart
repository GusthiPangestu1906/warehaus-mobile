import 'package:zone/domain/repositories/zone_repository.dart';

import '../entities/zone.dart';

class GetZoneByAisle {
  final ZoneRepository repository;
  GetZoneByAisle(this.repository);

  Future<List<Zone>> call(int zoneId, int aisleNumber) {
    return repository.getZonesByAisle(zoneId, aisleNumber);
  }
}
