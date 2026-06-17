import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:zone/data/models/zone_model.dart';
import 'package:zone/domain/params/create_zone_param.dart';

class ZoneApiDatasource {
  final Dio dio;
  ZoneApiDatasource(this.dio);

  static const String _zonePath = '/zones';

  Future<List<ZoneModel>> getZones() async {
    final response = await dio.get(_zonePath);
    final data = response.data;

    debugPrint('Runtime type: ${data.runtimeType}');
    debugPrint('Response data: $data');

    // 1. Jika backend mengembalikan List (Array)
    if (data is List) {
      return data
          .map((e) => ZoneModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // 2. Jika backend ternyata hanya mengembalikan satu Object (Map)
    if (data is Map<String, dynamic>) {
      return [ZoneModel.fromJson(data)];
    }

    // 3. Jika backend membungkus list-nya di dalam key tertentu (misal: data['results'] atau data['data'])
    if (data is Map && data.containsKey('data') && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => ZoneModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // 4. Cek various common wrapper keys yang mungkin digunakan backend
    final List<ZoneModel> zonesFromWrapper = _extractZonesFromWrapper(data);
    if (zonesFromWrapper.isNotEmpty) {
      return zonesFromWrapper;
    }

    throw Exception(
      'Unexpected response type for getZones: ${data.runtimeType}',
    );
  }

  Future<List<ZoneModel>> getZonesByAisle(int zoneId, int aisleNumber) async {
    final response = await dio.get('$_zonePath/$zoneId/$aisleNumber');
    final data = response.data;

    debugPrint('Runtime type: ${response.data.runtimeType}');
    debugPrint('Response data: ${response.data}');

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

  Future<ZoneModel?> getZoneById(int id) async {
    final response = await dio.get('$_zonePath/$id');
    debugPrint('Runtime type: ${response.data.runtimeType}');
    debugPrint('Response data: ${response.data}');
    debugPrint('getZoneById response: ${response.data}');
    return ZoneModel.fromJson(response.data);
  }

  Future<void> createZone(CreateZoneParam zone) async {
    await dio.post(_zonePath, data: zone.toJson());
  }

  Future<void> updateZone({
    required int id,
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

  Future<void> deleteZone(int id) async {
    await dio.delete('$_zonePath/$id');
  }

  Future<Map<String, dynamic>> getShelfDetails(int shelfId) async {
    final response = await dio.get('$_zonePath/shelves/$shelfId');
    return response.data as Map<String, dynamic>;
  }

  /// Helper method untuk mengekstrak zones dari berbagai format response wrapper
  List<ZoneModel> _extractZonesFromWrapper(dynamic data) {
    if (data is! Map) return [];

    // List of common wrapper keys yang mungkin digunakan backend
    final wrapperKeys = ['results', 'zones', 'items', 'output', 'response'];

    for (final key in wrapperKeys) {
      if (data.containsKey(key) && data[key] is List) {
        final list = data[key] as List;
        if (list.isNotEmpty) {
          return list
              .map((e) => ZoneModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    }

    return [];
  }

  Future<List<int>> downloadAisleQr({
    required int zoneId,
    required int aisleNumber,
    required String format,
  }) async {
    final path = format.toLowerCase() == 'pdf'
        ? '$_zonePath/$zoneId/aisles/$aisleNumber/qrcodes/download-pdf'
        : '$_zonePath/$zoneId/aisles/$aisleNumber/qrcodes/download';

    final response = await dio.get<List<int>>(
      path,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );
    return response.data ?? [];
  }

  Future<List<int>> downloadShelfQr({
    required int shelfId,
    required String format,
  }) async {
    final path = format.toLowerCase() == 'pdf'
        ? '$_zonePath/shelves/$shelfId/qrcode/download-pdf'
        : '$_zonePath/shelves/$shelfId/qrcode/download';

    final response = await dio.get<List<int>>(
      path,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );
    return response.data ?? [];
  }
}
