import 'package:dio/dio.dart';

class OutboundProductApiDatasource {
  final Dio dio;
  OutboundProductApiDatasource(this.dio);

  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await dio.get('/products');
    return (response.data as List).cast<Map<String, dynamic>>();
  }
}
