import 'package:zone/domain/repositories/zone_repository.dart';

import '../entities/zone.dart';

class GetZoneDetails {
  final ZoneRepository repository;
  GetZoneDetails(this.repository);

  Future<Zone> call(int id) {
    return repository.getZoneDetails(id);
  }
}
