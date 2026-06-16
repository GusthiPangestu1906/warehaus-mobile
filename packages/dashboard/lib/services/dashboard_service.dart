import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DashboardService {
  final Dio dio;
  DashboardService(this.dio);

  Future<int> getProductCount() async {
    final response = await dio.get('/api/products');
    if (response.statusCode == 200) {
      final products = response.data as List;
      return products.length;
    }
    return 0;
  }

  Future<List<ActivityLog>> getRecentLogs({int limit = 10}) async {
    try {
      final response = await dio.get(
        '/api/dashboard/recent-logs',
        queryParameters: {'limit': limit},
      );
      debugPrint('[DashboardService] Response: $response');
      debugPrint('[DashboardService] Response data: ${response.data}');

      final logs = response.data as List;
      return logs
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
}

class ActivityLog {
  final int id;
  final String type;
  final String title;
  final String subtitle;
  final String time;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      time: json['time'] as String? ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  bool get isStockIn =>
      type.toLowerCase().contains('in') || type.toLowerCase().contains('away');
  bool get isStockOut =>
      type.toLowerCase().contains('out') || type.toLowerCase().contains('pick');
}
