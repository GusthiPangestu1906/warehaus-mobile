import 'package:core_services/core_services.dart';
import 'package:dio/dio.dart';
import 'package:auth/data/models/token_response_model.dart';

abstract class AuthRemoteDatasource {
  Future<TokenResponseModel> login({
    required String email,
    required String password,
  });
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final ApiClient _apiClient;

  AuthRemoteDatasourceImpl(this._apiClient);

  @override
  Future<TokenResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      '/connect/token',
      data: {'grant_type': 'password', 'email': email, 'password': password},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    return TokenResponseModel.fromJson(response.data);
  }
}
