class OrderModel {
  final String orderId;
  final String customerId;
  final String customerName;   // ✅ Mpya
  final String customerPhone;  // ✅ Mpya
  final String shopId;
  final String? deliveryPersonId;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String deliveryAddress;
  final DateTime createdAt;

  OrderModel({
    required this.orderId,
    required this.customerId,
    this.customerName = '',   // ✅ Default tupu (backwards compatible)
    this.customerPhone = '',  // ✅ Default tupu (backwards compatible)
    required this.shopId,
    this.deliveryPersonId,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.deliveryAddress,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'shopId': shopId,
      'deliveryPersonId': deliveryPersonId,
      'items': items,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'deliveryAddress': deliveryAddress,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',   // ✅ backwards compatible
      customerPhone: map['customerPhone'] ?? '', // ✅ backwards compatible
      shopId: map['shopId'] ?? '',
      deliveryPersonId: map['deliveryPersonId'],
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      paymentStatus: map['paymentStatus'] ?? '',
      orderStatus: map['orderStatus'] ?? '',
      deliveryAddress: map['deliveryAddress'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
