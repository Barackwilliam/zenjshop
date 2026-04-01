import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/delivery_model.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../models/notification_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== USERS ====================
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      return null;
    } catch (e) { return null; }
  }

  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection('users').snapshots()
        .map((s) => s.docs.map((d) => UserModel.fromMap(d.data())).toList());
  }

  // ==================== SHOPS ====================
  Future<bool> addShop(ShopModel shop) async {
    try {
      await _firestore.collection('shops').doc(shop.shopId).set(shop.toMap());
      return true;
    } catch (e) { return false; }
  }

  Stream<List<ShopModel>> getActiveShops() {
    return _firestore.collection('shops').where('status', isEqualTo: 'active')
        .snapshots().map((s) => s.docs.map((d) => ShopModel.fromMap(d.data())).toList());
  }

  Stream<List<ShopModel>> getAllShops() {
    return _firestore.collection('shops').snapshots()
        .map((s) => s.docs.map((d) => ShopModel.fromMap(d.data())).toList());
  }

  Stream<List<ShopModel>> getMyShops(String ownerId) {
    return _firestore.collection('shops').where('ownerId', isEqualTo: ownerId)
        .snapshots().map((s) => s.docs.map((d) => ShopModel.fromMap(d.data())).toList());
  }

  Future<bool> updateShopStatus(String shopId, String status) async {
    try {
      await _firestore.collection('shops').doc(shopId).update({'status': status});
      return true;
    } catch (e) { return false; }
  }

  Future<bool> updateShopImage(String shopId, String imageUrl) async {
    try {
      await _firestore.collection('shops').doc(shopId).update({'shopImage': imageUrl});
      return true;
    } catch (e) { return false; }
  }

  Future<bool> deleteShop(String shopId) async {
    try {
      await _firestore.collection('shops').doc(shopId).delete();
      return true;
    } catch (e) { return false; }
  }

  // ==================== PRODUCTS ====================
  Future<bool> addProduct(ProductModel product) async {
    try {
      await _firestore.collection('products').doc(product.productId).set(product.toMap());
      return true;
    } catch (e) { return false; }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      return true;
    } catch (e) { return false; }
  }

  Future<bool> updateProductAvailability(String productId, bool isAvailable) async {
    try {
      await _firestore.collection('products').doc(productId).update({'isAvailable': isAvailable});
      return true;
    } catch (e) { return false; }
  }

  Stream<List<ProductModel>> getShopProducts(String shopId) {
    return _firestore.collection('products').where('shopId', isEqualTo: shopId)
        .snapshots().map((s) => s.docs.map((d) => ProductModel.fromMap(d.data())).toList());
  }

  Stream<List<ProductModel>> getAllProducts() {
    return _firestore.collection('products').where('isAvailable', isEqualTo: true)
        .snapshots().map((s) => s.docs.map((d) => ProductModel.fromMap(d.data())).toList());
  }

  // ==================== ORDERS ====================
  Future<bool> createOrder(OrderModel order) async {
    try {
      await _firestore.collection('orders').doc(order.orderId).set(order.toMap());
      // Notification kwa admin
      await sendNotification(
        userId: 'admin',
        title: 'New Order!',
        body: 'Order #${order.orderId.substring(0, 8)} has been placed',
        type: 'new_order',
        referenceId: order.orderId,
      );
      // Notification kwa shop owner
      try {
        final shopDoc = await _firestore.collection('shops').doc(order.shopId).get();
        if (shopDoc.exists) {
          final ownerId = shopDoc.data()?['ownerId'] as String?;
          if (ownerId != null && ownerId.isNotEmpty) {
            await sendNotification(
              userId: ownerId,
              title: 'Agizo Jipya!',
              body: 'Una agizo jipya #${order.orderId.substring(0, 8).toUpperCase()}',
              type: 'new_order',
              referenceId: order.orderId,
            );
          }
        }
      } catch (_) {}
      return true;
    } catch (e) { return false; }
  }

  /// Maagizo YOTE — kwa Admin peke yake
  Stream<List<OrderModel>> getAllOrders() {
    return _firestore.collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => OrderModel.fromMap(d.data())).toList());
  }

  /// Maagizo ya maduka ya shop owner — inatumia shopIds list
  Stream<List<OrderModel>> getShopOwnerOrders(List<String> shopIds) {
    if (shopIds.isEmpty) return Stream.value([]);
    final safeIds = shopIds.take(10).toList(); // Firestore whereIn limit = 10
    return _firestore.collection('orders')
        .where('shopId', whereIn: safeIds)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => OrderModel.fromMap(d.data())).toList());
  }

  Stream<List<OrderModel>> getCustomerOrders(String customerId) {
    return _firestore.collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => OrderModel.fromMap(d.data())).toList());
  }

  Stream<List<OrderModel>> getShopOrders(String shopId) {
    return _firestore.collection('orders')
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => OrderModel.fromMap(d.data())).toList());
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({'orderStatus': status});
      return true;
    } catch (e) { return false; }
  }

  Future<bool> assignDeliveryPerson(String orderId, String deliveryPersonId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({'deliveryPersonId': deliveryPersonId});
      return true;
    } catch (e) { return false; }
  }

  // ==================== DELIVERY ====================
  Future<bool> createDelivery(DeliveryModel delivery) async {
    try {
      await _firestore.collection('deliveries').doc(delivery.deliveryId).set(delivery.toMap());
      return true;
    } catch (e) { return false; }
  }

  Stream<List<DeliveryModel>> getDeliveryPersonOrders(String deliveryPersonId) {
    return _firestore.collection('deliveries')
        .where('deliveryPersonId', isEqualTo: deliveryPersonId)
        .snapshots()
        .map((s) => s.docs.map((d) => DeliveryModel.fromMap(d.data())).toList());
  }

  Stream<List<DeliveryModel>> getAllDeliveries() {
    return _firestore.collection('deliveries')
        .orderBy('assignedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => DeliveryModel.fromMap(d.data())).toList());
  }

  Future<bool> updateDeliveryStatus(String deliveryId, String status) async {
    try {
      final Map<String, dynamic> data = {'status': status};
      if (status == 'delivered') data['deliveredAt'] = DateTime.now().toIso8601String();
      await _firestore.collection('deliveries').doc(deliveryId).update(data);
      return true;
    } catch (e) { return false; }
  }

  // ==================== CHAT ====================
  Future<bool> sendMessage(ChatMessage message) async {
    try {
      final chatId = _getChatId(message.senderId, message.receiverId);
      await _firestore.collection('chats').doc(chatId)
          .collection('messages').doc(message.messageId).set(message.toMap());
      return true;
    } catch (e) { return false; }
  }

  Stream<List<ChatMessage>> getMessages(String userId1, String userId2) {
    final chatId = _getChatId(userId1, userId2);
    return _firestore.collection('chats').doc(chatId).collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map((d) => ChatMessage.fromMap(d.data())).toList());
  }

  String _getChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join('_');
  }

  // ==================== NOTIFICATIONS ====================
  Future<bool> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? referenceId,
  }) async {
    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch.toString();
      final notification = NotificationModel(
        notificationId: notificationId,
        userId: userId,
        title: title,
        body: body,
        type: type,
        referenceId: referenceId,
        isRead: false,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('notifications').doc(notificationId).set(notification.toMap());
      return true;
    } catch (e) { return false; }
  }

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore.collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => NotificationModel.fromMap(d.data())).toList());
  }

  Future<bool> markNotificationRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({'isRead': true});
      return true;
    } catch (e) { return false; }
  }

  Future<bool> markAllNotificationsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final snap = await _firestore.collection('notifications')
          .where('userId', isEqualTo: userId).where('isRead', isEqualTo: false).get();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
      return true;
    } catch (e) { return false; }
  }

  Stream<int> getUnreadNotificationsCount(String userId) {
    return _firestore.collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }
}
