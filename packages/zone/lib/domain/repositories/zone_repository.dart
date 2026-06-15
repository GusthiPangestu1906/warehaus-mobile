import '../entities/zone.dart';
// import '../entities/shelf_detail.dart'; // TODO: /v1/Zone/shelves/{shelfId} belum ada di backend

abstract class ZoneRepository {
  Future<List<Zone>> getZones();
  Future<List<Zone>> getZonesByAisle(String zoneId, int aisleNumber);
  Future<Zone> getZoneDetails(String id);
  // Future<ShelfDetail> getShelfDetails(int shelfId); // TODO: /v1/Zone/shelves/{shelfId} belum ada di backend
  Future<void> createZone(Zone zone);
  Future<void> updateZone({
    required String id,
    String? zoneName,
    String? category,
    String? description,
  });
  Future<void> deleteZone(String id);
}