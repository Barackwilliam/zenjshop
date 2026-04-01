class ProductModel {
  final String productId;
  final String shopId;
  final String name;
  final String description;
  final double price;
  final String? productImage;
  final String category;
  final int stock;
  final bool isAvailable;
  final DateTime createdAt;

  ProductModel({
    required this.productId,
    required this.shopId,
    required this.name,
    required this.description,
    required this.price,
    this.productImage,
    required this.category,
    required this.stock,
    required this.isAvailable,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'shopId': shopId,
      'name': name,
      'description': description,
      'price': price,
      'productImage': productImage,
      'category': category,
      'stock': stock,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['productId'],
      shopId: map['shopId'],
      name: map['name'],
      description: map['description'],
      price: map['price'].toDouble(),
      productImage: map['productImage'],
      category: map['category'],
      stock: map['stock'],
      isAvailable: map['isAvailable'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
