class Product {
  final int productId;
  final String productName;
  final String description;
  final double thickness;
  final String size;
  final String imagePath;

  Product({
    required this.productId,
    required this.productName,
    required this.description,
    required this.thickness,
    required this.size,
    required this.imagePath,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        productId: json['productId'] ?? 0,
        productName: json['productName'] ?? '',
        description: json['description'] ?? '',
        thickness: (json['thickness'] as num?)?.toDouble() ?? 0,
        size: json['size'] ?? '',
        imagePath: json['imagePath'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'description': description,
        'thickness': thickness,
        'size': size,
        'imagePath': imagePath,
      };
}
