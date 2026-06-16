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

  Future<List<ActivityLog>> getRecentLogs({int limit = 10}) async {
    try {
      final response = await dio.get(
        '/dashboard/recent-logs',
        queryParameters: {'limit': limit},
      );

      debugPrint('[DashboardService] Response data: ${response.data}');

      final logsList = response.data as List<dynamic>? ?? [];

      return logsList
          .map((log) => ActivityLog.fromJson(log as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[DashboardService] Error: $e');
      if (e is DioException && e.response?.statusCode == 404) {
        return const [];
      }
      rethrow;
    }
  }

  Future<DashboardResponse?> getDashboardData({int limit = 10}) async {
    try {
      final response = await dio.get('/dashboard');

      // Casting response.data ke Map
      final responseData = response.data as Map<String, dynamic>;
      return DashboardResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('[DashboardService] Error: $e');
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }
}
