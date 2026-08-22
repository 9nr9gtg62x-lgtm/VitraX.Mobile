class ProductionOrder {
  final int orderId;
  final int productId;
  final int quantity;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String notes;

  ProductionOrder({
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.notes,
  });

  factory ProductionOrder.fromJson(Map<String, dynamic> json) => ProductionOrder(
        orderId: json['orderId'] ?? 0,
        productId: json['productId'] ?? 0,
        quantity: json['quantity'] ?? 0,
        startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
        endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
        status: json['status'] ?? '',
        notes: json['notes'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'productId': productId,
        'quantity': quantity,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status,
        'notes': notes,
      };
}
