import 'package:dio/dio.dart';

class RegionApiDatasource {
  final Dio dio;
  RegionApiDatasource(this.dio);

  /// GET /couriers
  Future<List<Map<String, dynamic>>> getCouriers() async {
    final response = await dio.get('/couriers');
    return _asMapList(response.data);
  }

  /// GET /regions/province
  Future<List<Map<String, dynamic>>> getProvinces() async {
    final response = await dio.get('/regions/province');
    return _asMapList(response.data);
  }

  /// GET /regions/city?provinceCode=X
  Future<List<Map<String, dynamic>>> getCities(String provinceCode) async {
    final response = await dio.get(
      '/regions/city',
      queryParameters: {'provinceCode': provinceCode},
    );
    return _asMapList(response.data);
  }

  /// GET /regions/district?cityCode=X
  Future<List<Map<String, dynamic>>> getDistricts(String cityCode) async {
    final response = await dio.get(
      '/regions/district',
      queryParameters: {'cityCode': cityCode},
    );
    return _asMapList(response.data);
  }

  List<Map<String, dynamic>> _asMapList(dynamic data) {
    final rawList = _extractList(data);

    if (rawList is! List) {
      return const [];
    }

    return rawList
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  dynamic _extractList(dynamic data) {
    if (data is List) return data;
    if (data is! Map) return null;

    final map = Map<String, dynamic>.from(data);
    for (final key in const [
      'value',
      'Value',
      'data',
      'Data',
      'items',
      'Items',
      'result',
      'Result',
      'results',
      'Results',
    ]) {
      final value = map[key];
      if (value is List) return value;
    }

    final nestedData = map['data'] ?? map['Data'];
    if (nestedData is Map) {
      return _extractList(nestedData);
    }

    return null;
  }
}
