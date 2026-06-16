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

class DashboardResponse {
  final PendingTask? pendingTask;
  final int totalThroughput;
  final List<ActivityLog> logs;

  DashboardResponse({
    this.pendingTask,
    required this.totalThroughput,
    required this.logs,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      pendingTask: json['pendingTask'] != null
          ? PendingTask.fromJson(json['pendingTask'] as Map<String, dynamic>)
          : null,
      totalThroughput: json['totalThroughput'] as int? ?? 0,
      logs:
          (json['logs'] as List<dynamic>?)
              ?.map((log) => ActivityLog.fromJson(log as Map<String, dynamic>))
              .toList() ??
          [],
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
