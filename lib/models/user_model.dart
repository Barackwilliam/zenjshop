class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String role; // 'admin', 'customer', 'shop_owner', 'delivery'
  final String? profileImage;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.profileImage,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      phone: map['phone'],
      role: map['role'],
      profileImage: map['profileImage'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
