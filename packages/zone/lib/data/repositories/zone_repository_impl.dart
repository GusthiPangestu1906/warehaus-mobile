import 'package:zone/data/datasources/zone_api_datasource.dart';
import 'package:zone/data/models/zone_model.dart';
import 'package:zone/domain/entities/zone.dart';
import 'package:zone/domain/entities/shelf_detail.dart';
import 'package:zone/domain/params/create_zone_param.dart';
import 'package:zone/domain/repositories/zone_repository.dart';

class ZoneRepositoryImpl implements ZoneRepository {
  final ZoneApiDatasource apiDatasource;
  ZoneRepositoryImpl(this.apiDatasource);

  @override
  Future<List<Zone>> getZones() async {
    final zones = await apiDatasource.getZones();
    final detailedZones = await Future.wait(
      zones.map((zone) async {
        final detailedZone = await apiDatasource.getZoneById(zone.id);
        return detailedZone ?? zone;
      }),
    );
    return detailedZones;
  }

  @override
  Future<List<Zone>> getZonesByAisle(String zoneId, int aisleNumber) async {
    return await apiDatasource.getZonesByAisle(zoneId, aisleNumber);
  }

  @override
  Future<Zone> getZoneDetails(String id) async {
    final zone = await apiDatasource.getZoneById(id);
    if (zone == null) {
      throw Exception('Zone with id $id not found');
    }
    return zone;
  }

  @override
  Future<void> createZone(CreateZoneParam zone) async {
    await apiDatasource.createZone(zone);
  }

  @override
  Future<void> updateZone({
    required String id,
    String? zoneName,
    int? categoryId,
    String? description,
  }) async {
    await apiDatasource.updateZone(
      id: id,
      zoneName: zoneName,
      categoryId: categoryId,
      description: description,
    );
  }

  @override
  Future<void> deleteZone(String id) async {
    await apiDatasource.deleteZone(id);
  }

  @override
  Future<ShelfDetail> getShelfDetails(int shelfId) async {
    final data = await apiDatasource.getShelfDetails(shelfId);
    return ShelfDetail.fromJson(data);
  }
}
