import 'package:dio/dio.dart';
import 'package:zone/data/models/zone_model.dart';
import 'package:zone/domain/params/create_zone_param.dart';

class ZoneApiDatasource {
  final Dio dio;
  ZoneApiDatasource(this.dio);

  static const String _zonePath = '/Zones';

  Future<List<ZoneModel>> getZones() async {
    final response = await dio.get(_zonePath);
    return (response.data as List).map((e) => ZoneModel.fromJson(e)).toList();
  }

  Future<List<ZoneModel>> getZonesByAisle(
    String zoneId,
    int aisleNumber,
  ) async {
    final response = await dio.get('$_zonePath/$zoneId/$aisleNumber');
    final data = response.data;

    if (data is List) {
      return data
          .map((e) => ZoneModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      return [ZoneModel.fromJson(data)];
    }

    throw Exception('Unexpected aisle response type: ${data.runtimeType}');
  }

  Future<ZoneModel?> getZoneById(String id) async {
    final response = await dio.get('$_zonePath/$id');
    return ZoneModel.fromJson(response.data);
  }

  Future<void> createZone(CreateZoneParam zone) async {
    await dio.post(_zonePath, data: zone.toJson());
  }

  Future<void> updateZone({
    required String id,
    String? zoneName,
    int? categoryId,
    String? description,
  }) async {
    final payload = <String, dynamic>{};
    if (zoneName != null) payload['zoneName'] = zoneName;
    if (categoryId != null) payload['categoryId'] = categoryId;
    if (description != null) payload['description'] = description;

    await dio.put('$_zonePath/$id', data: payload);
  }

  Future<void> deleteZone(String id) async {
    await dio.delete('$_zonePath/$id');
  }

  Future<Map<String, dynamic>> getShelfDetails(int shelfId) async {
    final response = await dio.get('$_zonePath/shelves/$shelfId');
    return response.data as Map<String, dynamic>;
  }
}
