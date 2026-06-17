import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DashboardService {
  final Dio dio;
  DashboardService(this.dio);

  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await dio.get('/api/dashboard');
      debugPrint('[DashboardService] Stats Response: ${response.data}');
      return DashboardStats.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[DashboardService] Error fetching stats: $e');
      rethrow;
    }
  }

  Future<List<ActivityLog>> getRecentLogs({int limit = 10}) async {
    try {
      final response = await dio.get(
        '/api/dashboard/recent-logs',
        queryParameters: {'limit': limit},
      );
      debugPrint('[DashboardService] Response data: ${response.data}');

      final logs = response.data as List;
      return logs
          .map((log) => ActivityLog.fromJson(log as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[DashboardService] Error fetching logs: $e');
      rethrow;
    }
  }
}

class DashboardStats {
  final PendingTask pendingTask;
  final int totalThroughput;
  final List<ActivityLog> logs;

  DashboardStats({
    required this.pendingTask,
    required this.totalThroughput,
    required this.logs,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      pendingTask: PendingTask.fromJson(
        json['pendingTask'] as Map<String, dynamic>? ?? {},
      ),
      totalThroughput: json['totalThroughput'] as int? ?? 0,
      logs: json['logs'] != null
          ? (json['logs'] as List)
          .map((log) => ActivityLog.fromJson(log as Map<String, dynamic>))
          .toList()
          : [],
    );
  }
}

class PendingTask {
  final int totalPendingTask;
  final int inboundPendingTask;
  final int outboundPendingTask;

  PendingTask({
    required this.totalPendingTask,
    required this.inboundPendingTask,
    required this.outboundPendingTask,
  });

  factory PendingTask.fromJson(Map<String, dynamic> json) {
    return PendingTask(
      totalPendingTask: json['totalPendingTask'] as int? ?? 0,
      inboundPendingTask: json['inboundPendingTask'] as int? ?? 0,
      outboundPendingTask: json['outboundPendingTask'] as int? ?? 0,
    );
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