import 'package:dio/dio.dart';
import 'package:product/product.dart';
import 'package:outbound/data/models/form/courier_model.dart';
import 'package:outbound/data/models/form/region_model.dart';

class FormApiDatasource {
  final Dio dio;
  FormApiDatasource(this.dio);

  Future<List<ProductModel>> getProducts() async {
    final response = await dio.get('/products');
    return (response.data as List)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CourierModel>> getCouriers() async {
    final response = await dio.get('/couriers');
    return (response.data as List)
        .map((e) => CourierModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RegionModel>> getProvinces() async {
    final response = await dio.get('/regions/province');
    return (response.data as List)
        .map((e) => RegionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RegionModel>> getCities(String provinceCode) async {
    final response = await dio.get('/regions/city/$provinceCode');
    return (response.data as List)
        .map((e) => RegionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RegionModel>> getDistricts(String cityCode) async {
    final response = await dio.get('/regions/district/$cityCode');
    return (response.data as List)
        .map((e) => RegionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
