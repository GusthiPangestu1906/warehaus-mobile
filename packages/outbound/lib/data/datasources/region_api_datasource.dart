import 'package:dio/dio.dart';

class RegionApiDatasource {
  final Dio dio;
  RegionApiDatasource(this.dio);

  /// GET /api/couriers
  Future<List<Map<String, dynamic>>> getCouriers() async {
    final response = await dio.get('/api/couriers');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  /// GET /api/regions/province
  Future<List<Map<String, dynamic>>> getProvinces() async {
    final response = await dio.get('/api/regions/province');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  /// GET /api/regions/city?provinceCode=X
  Future<List<Map<String, dynamic>>> getCities(String provinceCode) async {
    final response = await dio.get(
      '/api/regions/city',
      queryParameters: {'provinceCode': provinceCode},
    );
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  /// GET /api/regions/district?cityCode=X
  Future<List<Map<String, dynamic>>> getDistricts(String cityCode) async {
    final response = await dio.get(
      '/api/regions/district',
      queryParameters: {'cityCode': cityCode},
    );
    return (response.data as List).cast<Map<String, dynamic>>();
  }
}