import 'dart:convert';

import 'package:flutter/foundation.dart';

class PendingTask {
  final int totalPendingTask;
  final int inboundPendingTask;
  final int outboundPendingTask;

  PendingTask({
    required this.totalPendingTask,
    required this.inboundPendingTask,
    required this.outboundPendingTask,
  });

  factory PendingTask.fromJson(dynamic json) {
    if (json is Map) {
      final map = Map<String, dynamic>.from(json);
      return PendingTask(
        // Menggunakan int.tryParse + toString() agar kebal dari TypeError jika backend mengirim String/Int/Double
        totalPendingTask:
            int.tryParse(map['totalPendingTask']?.toString() ?? '0') ?? 0,
        inboundPendingTask:
            int.tryParse(map['inboundPendingTask']?.toString() ?? '0') ?? 0,
        outboundPendingTask:
            int.tryParse(map['outboundPendingTask']?.toString() ?? '0') ?? 0,
      );
    }
    return PendingTask(
      totalPendingTask: 0,
      inboundPendingTask: 0,
      outboundPendingTask: 0,
    );
  }
}

class DashboardResponse {
  final PendingTask? pendingTask;
  final int totalThroughput;
  final List<ActivityLog> logs;

  DashboardResponse({
    this.pendingTask,
    required this.totalThroughput,
    required this.logs,
  });

  factory DashboardResponse.fromJson(dynamic json) {
    // 1. ANTISIPASI: Jika data dari API ternyata berupa String JSON mentah, decode otomatis
    if (json is String) {
      try {
        json = jsonDecode(json);
      } catch (e) {
        debugPrint('[DashboardResponse] Gagal men-decode String JSON: $e');
        return DashboardResponse(
          pendingTask: null,
          totalThroughput: 0,
          logs: [],
        );
      }
    }

    // KONDISI A: Jika API ternyata masih mengirim FORMAT LAMA (Berupa List langsung)
    if (json is List) {
      return DashboardResponse(
        pendingTask: null,
        totalThroughput: 0,
        logs: json.map((log) => ActivityLog.fromJson(log)).toList(),
      );
    }

    // KONDISI B: Jika API sudah menggunakan FORMAT BARU (Berupa Map/Object)
    if (json is Map) {
      final map = Map<String, dynamic>.from(json);

      return DashboardResponse(
        pendingTask: map['pendingTask'] != null
            ? PendingTask.fromJson(map['pendingTask'])
            : null,
        totalThroughput:
            int.tryParse(map['totalThroughput']?.toString() ?? '0') ?? 0,
        logs:
            (map['logs'] as List<dynamic>?)
                ?.map((log) => ActivityLog.fromJson(log))
                .toList() ??
            [],
      );
    }

    return DashboardResponse(pendingTask: null, totalThroughput: 0, logs: []);
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

  factory ActivityLog.fromJson(dynamic json) {
    if (json is Map) {
      final map = Map<String, dynamic>.from(json);
      return ActivityLog(
        id: int.tryParse(map['id']?.toString() ?? '0') ?? 0,
        type: map['type']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        subtitle: map['subtitle']?.toString() ?? '',
        time: map['time']?.toString() ?? '',
        createdAt:
            DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      );
    }
    return ActivityLog(
      id: 0,
      type: '',
      title: '',
      subtitle: '',
      time: '',
      createdAt: DateTime.now(),
    );
  }

  bool get isStockIn =>
      type.toLowerCase().contains('in') || type.toLowerCase().contains('away');
  bool get isStockOut =>
      type.toLowerCase().contains('out') || type.toLowerCase().contains('pick');
}
