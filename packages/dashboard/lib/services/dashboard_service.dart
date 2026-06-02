import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DashboardService {
  final Dio dio;
  DashboardService(this.dio);

  Future<int> getProductCount() async {
    final response = await dio.get('/v1/Product');
    if (response.statusCode == 200) {
      final products = response.data as List;
      return products.length;
    }
    return 0;
  }

  Future<List<ActivityLog>> getRecentLogs({int limit = 10}) async {
    try {
      final response = await dio.get(
        '/v1/Dashboard/recent-logs',
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
      rethrow;
    }
  }
}

class ActivityLog {
  final int id;
  final String type;
  final String title;
  final String productName;
  final String sku;
  final String locationName;
  final int quantity;
  final int stockAfterMovement;
  final String time;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.type,
    required this.title,
    required this.productName,
    required this.sku,
    required this.locationName,
    required this.quantity,
    required this.stockAfterMovement,
    required this.time,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      locationName: json['locationName'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      stockAfterMovement: json['stockAfterMovement'] as int? ?? 0,
      time: json['time'] as String? ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  bool get isStockIn => type.toLowerCase() == 'stock in';
  bool get isStockOut => type.toLowerCase() == 'stock out';
}
