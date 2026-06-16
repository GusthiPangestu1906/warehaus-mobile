import 'package:zone/domain/params/create_zone_param.dart';

import '../entities/zone.dart';
import '../entities/shelf_detail.dart';

abstract class ZoneRepository {
  Future<List<Zone>> getZones();
  Future<List<Zone>> getZonesByAisle(String zoneId, int aisleNumber);
  Future<Zone> getZoneDetails(String id);
  Future<ShelfDetail> getShelfDetails(int shelfId);
  Future<void> createZone(CreateZoneParam zone);
  Future<void> updateZone({
    required String id,
    String? zoneName,
    String? category,
    String? description,
  });
  Future<void> deleteZone(String id);
}
