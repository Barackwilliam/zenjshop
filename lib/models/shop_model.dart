class ShopModel {
  final String shopId;
  final String ownerId;
  final String name;
  final String description;
  final String category;
  final String? shopImage;
  final String location;
  final String status; // 'pending', 'active', 'suspended'
  final DateTime createdAt;

  ShopModel({
    required this.shopId,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.category,
    this.shopImage,
    required this.location,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'category': category,
      'shopImage': shopImage,
      'location': location,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ShopModel.fromMap(Map<String, dynamic> map) {
    return ShopModel(
      shopId: map['shopId'],
      ownerId: map['ownerId'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      shopImage: map['shopImage'],
      location: map['location'],
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
