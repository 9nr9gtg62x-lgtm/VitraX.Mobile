class ProductionTask {
  final int taskId;
  final int orderId;
  final int workerId;
  final String stage;
  final String status;
  final DateTime startTime;
  final DateTime endTime;

  ProductionTask({
    required this.taskId,
    required this.orderId,
    required this.workerId,
    required this.stage,
    required this.status,
    required this.startTime,
    required this.endTime,
  });

  factory ProductionTask.fromJson(Map<String, dynamic> json) => ProductionTask(
        taskId: json['taskId'] ?? 0,
        orderId: json['orderId'] ?? 0,
        workerId: json['workerId'] ?? 0,
        stage: json['stage'] ?? '',
        status: json['status'] ?? '',
        startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
        endTime: DateTime.tryParse(json['endTime'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'orderId': orderId,
        'workerId': workerId,
        'stage': stage,
        'status': status,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      };
}
