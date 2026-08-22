class Worker {
  final int workerId;
  final String workerName;
  final String role;
  final String phone;
  final String imagePath;

  Worker({
    required this.workerId,
    required this.workerName,
    required this.role,
    required this.phone,
    required this.imagePath,
  });

  factory Worker.fromJson(Map<String, dynamic> json) => Worker(
        workerId: json['workerId'] ?? 0,
        workerName: json['workerName'] ?? '',
        role: json['role'] ?? '',
        phone: json['phone'] ?? '',
        imagePath: json['imagePath'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'workerId': workerId,
        'workerName': workerName,
        'role': role,
        'phone': phone,
        'imagePath': imagePath,
      };
}
