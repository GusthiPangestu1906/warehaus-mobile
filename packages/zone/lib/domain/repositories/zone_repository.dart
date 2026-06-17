import 'package:zone/domain/params/create_zone_param.dart';

import '../entities/shelf_detail.dart';
import '../entities/zone.dart';

abstract class ZoneRepository {
  Future<List<Zone>> getZones();
  Future<List<Zone>> getZonesByAisle(int zoneId, int aisleNumber);
  Future<Zone> getZoneDetails(int id);
  Future<ShelfDetail> getShelfDetails(int shelfId);
  Future<void> createZone(CreateZoneParam zone);
  Future<void> updateZone({
    required int id,
    String? zoneName,
    int? categoryId,
    String? description,
  });
  Future<void> deleteZone(int id);
}
