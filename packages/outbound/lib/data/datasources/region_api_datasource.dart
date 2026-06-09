import 'package:dio/dio.dart';

class RegionApiDatasource {
  final Dio dio;
  RegionApiDatasource(this.dio);

  /// GET /api/couriers
  Future<List<Map<String, dynamic>>> getCouriers() async {
    final response = await dio.get('/api/couriers');
    return _asMapList(response.data);
  }

  /// GET /api/regions/province
  Future<List<Map<String, dynamic>>> getProvinces() async {
    final response = await dio.get('/api/regions/province');
    return _asMapList(response.data);
  }

  /// GET /api/regions/city?provinceCode=X
  Future<List<Map<String, dynamic>>> getCities(String provinceCode) async {
    final response = await dio.get(
      '/api/regions/city',
      queryParameters: {'provinceCode': provinceCode},
    );
    return _asMapList(response.data);
  }

  /// GET /api/regions/district?cityCode=X
  Future<List<Map<String, dynamic>>> getDistricts(String cityCode) async {
    final response = await dio.get(
      '/api/regions/district',
      queryParameters: {'cityCode': cityCode},
    );
    return _asMapList(response.data);
  }

  List<Map<String, dynamic>> _asMapList(dynamic data) {
    final rawList = data is List
        ? data
        : data is Map<String, dynamic>
        ? data['value'] ?? data['data'] ?? data['items'] ?? data['result']
        : null;

    if (rawList is! List) {
      return const [];
    }

    return rawList.whereType<Map<String, dynamic>>().toList();
  }
}
