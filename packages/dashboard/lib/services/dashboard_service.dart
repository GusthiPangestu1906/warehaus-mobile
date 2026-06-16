import 'package:dashboard/services/model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DashboardService {
  final Dio dio;
  DashboardService(this.dio);

  Future<int> getProductCount() async {
    final response = await dio.get('/products');
    if (response.statusCode == 200) {
      final products = response.data as List;
      return products.length;
    }
    return 0;
  }

  Future<DashboardResponse?> getDashboardData({int limit = 10}) async {
    try {
      final response = await dio.get(
        '/dashboard',
        queryParameters: {'limit': limit},
      );

      debugPrint('[DashboardService] Raw Data Type: ${response}');

      final logsList = response.data as List<dynamic>? ?? [];

      return logsList
          .map((log) => ActivityLog.fromJson(log as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[DashboardService] Error di getDashboardData: $e');
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<List<ActivityLog>> getRecentLogs({int limit = 10}) async {
    try {
      final response = await dio.get('/dashboard');

      List<dynamic> logsList = [];

      if (response.data is Map) {
        final responseData = response.data as Map<String, dynamic>;
        logsList = responseData['logs'] as List<dynamic>? ?? [];
      } else if (response.data is List) {
        logsList = response.data as List<dynamic>;
      }

      return logsList
          .map((log) => ActivityLog.fromJson(log as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[DashboardService] Error di getRecentLogs: $e');
      if (e is DioException && e.response?.statusCode == 404) {
        return const [];
      }
      rethrow;
    }
  }
}
