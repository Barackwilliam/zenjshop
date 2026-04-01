class DeliveryModel {
  final String deliveryId;
  final String orderId;
  final String deliveryPersonId;
  final String shopId;
  final String customerId;
  final String status; // 'assigned', 'picked_up', 'on_the_way', 'delivered'
  final String shopLocation;
  final String customerLocation;
  final DateTime assignedAt;
  final DateTime? deliveredAt;

  DeliveryModel({
    required this.deliveryId,
    required this.orderId,
    required this.deliveryPersonId,
    required this.shopId,
    required this.customerId,
    required this.status,
    required this.shopLocation,
    required this.customerLocation,
    required this.assignedAt,
    this.deliveredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'deliveryId': deliveryId,
      'orderId': orderId,
      'deliveryPersonId': deliveryPersonId,
      'shopId': shopId,
      'customerId': customerId,
      'status': status,
      'shopLocation': shopLocation,
      'customerLocation': customerLocation,
      'assignedAt': assignedAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }

  factory DeliveryModel.fromMap(Map<String, dynamic> map) {
    return DeliveryModel(
      deliveryId: map['deliveryId'],
      orderId: map['orderId'],
      deliveryPersonId: map['deliveryPersonId'],
      shopId: map['shopId'],
      customerId: map['customerId'],
      status: map['status'],
      shopLocation: map['shopLocation'],
      customerLocation: map['customerLocation'],
      assignedAt: DateTime.parse(map['assignedAt']),
      deliveredAt:
          map['deliveredAt'] != null
              ? DateTime.parse(map['deliveredAt'])
              : null,
    );
  }
}
