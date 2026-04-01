class OrderModel {
  final String orderId;
  final String customerId;
  final String shopId;
  final String? deliveryPersonId;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String paymentMethod; // 'mpesa', 'tigo', 'airtel'
  final String paymentStatus; // 'pending', 'paid'
  final String
  orderStatus; // 'pending', 'confirmed', 'preparing', 'picked_up', 'delivered'
  final String deliveryAddress;
  final DateTime createdAt;

  OrderModel({
    required this.orderId,
    required this.customerId,
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
      orderId: map['orderId'],
      customerId: map['customerId'],
      shopId: map['shopId'],
      deliveryPersonId: map['deliveryPersonId'],
      items: List<Map<String, dynamic>>.from(map['items']),
      totalAmount: map['totalAmount'].toDouble(),
      paymentMethod: map['paymentMethod'],
      paymentStatus: map['paymentStatus'],
      orderStatus: map['orderStatus'],
      deliveryAddress: map['deliveryAddress'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
