import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/delivery_model.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../models/notification_model.dart';
import '../config/lang.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===== USERS =====
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) return UserModel.fromMap(doc.data()!);
      return null;
    } catch (_) { return null; }
  }

  Stream<List<UserModel>> getAllUsers() =>
      _db.collection('users').snapshots()
          .map((s) => s.docs.map((d) => UserModel.fromMap(d.data())).toList());

  Future<bool> updateUserProfile(String uid,
      {String? name, String? phone, String? profileImage, String? address}) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (profileImage != null) data['profileImage'] = profileImage;
      if (address != null) data['address'] = address;
      await _db.collection('users').doc(uid).update(data);
      return true;
    } catch (_) { return false; }
  }

  // ===== SHOPS =====
  Future<bool> addShop(ShopModel shop) async {
    try {
      await _db.collection('shops').doc(shop.shopId).set(shop.toMap());
      return true;
    } catch (_) { return false; }
  }

  Future<bool> deleteShop(String shopId) async {
    try {
      await _db.collection('shops').doc(shopId).delete();
      return true;
    } catch (_) { return false; }
  }

  Future<bool> deleteShopCascade(String shopId) async {
    try {
      final products = await _db.collection('products')
          .where('shopId', isEqualTo: shopId).get();
      final batch = _db.batch();
      for (final doc in products.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_db.collection('shops').doc(shopId));
      await batch.commit();
      return true;
    } catch (_) { return false; }
  }

  Future<bool> deleteUserFromFirestore(String uid) async {
    try {
      await _db.collection('users').doc(uid).delete();
      return true;
    } catch (_) { return false; }
  }

  Stream<List<ShopModel>> getActiveShops() =>
      _db.collection('shops').where('status', isEqualTo: 'active').snapshots()
          .map((s) => s.docs.map((d) => ShopModel.fromMap(d.data())).toList());

  Stream<List<ShopModel>> getAllShops() =>
      _db.collection('shops').snapshots()
          .map((s) => s.docs.map((d) => ShopModel.fromMap(d.data())).toList());

  Stream<List<ShopModel>> getMyShops(String ownerId) =>
      _db.collection('shops').where('ownerId', isEqualTo: ownerId).snapshots()
          .map((s) => s.docs.map((d) => ShopModel.fromMap(d.data())).toList());

  Future<ShopModel?> getShopById(String shopId) async {
    try {
      final doc = await _db.collection('shops').doc(shopId).get();
      if (doc.exists) return ShopModel.fromMap(doc.data()!);
      return null;
    } catch (_) { return null; }
  }

  Future<bool> updateShopStatus(String shopId, String status) async {
    try {
      await _db.collection('shops').doc(shopId).update({'status': status});
      return true;
    } catch (_) { return false; }
  }

  Future<bool> updateShopImage(String shopId, String imageUrl) async {
    try {
      await _db.collection('shops').doc(shopId).update({'shopImage': imageUrl});
      return true;
    } catch (_) { return false; }
  }

  // ===== PRODUCTS =====
  Future<bool> addProduct(ProductModel product) async {
    try {
      await _db.collection('products').doc(product.productId).set(product.toMap());
      return true;
    } catch (_) { return false; }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _db.collection('products').doc(productId).delete();
      return true;
    } catch (_) { return false; }
  }

  Future<bool> updateProductImage(String productId, String imageUrl) async {
    try {
      await _db.collection('products').doc(productId).update({'productImage': imageUrl});
      return true;
    } catch (_) { return false; }
  }

  Future<bool> updateProductAvailability(String productId, bool isAvailable) async {
    try {
      await _db.collection('products').doc(productId).update({'isAvailable': isAvailable});
      return true;
    } catch (_) { return false; }
  }

  Stream<List<ProductModel>> getShopProducts(String shopId) =>
      _db.collection('products').where('shopId', isEqualTo: shopId).snapshots()
          .map((s) => s.docs.map((d) => ProductModel.fromMap(d.data())).toList());

  Stream<List<ProductModel>> getAllProducts() =>
      _db.collection('products').where('isAvailable', isEqualTo: true).snapshots()
          .map((s) => s.docs.map((d) => ProductModel.fromMap(d.data())).toList());

  // ===== ORDERS =====
  Future<bool> createOrder(OrderModel order) async {
    try {
      await _db.collection('orders').doc(order.orderId).set(order.toMap());
      await sendNotification(
        userId: 'admin',
        title: 'New Order!',
        body: 'Order #${order.orderId.substring(0, 8)} placed',
        type: 'new_order',
        referenceId: order.orderId,
      );
      try {
        final shopDoc = await _db.collection('shops').doc(order.shopId).get();
        if (shopDoc.exists) {
          final ownerId = shopDoc.data()?['ownerId'] as String?;
          if (ownerId != null && ownerId.isNotEmpty) {
            await sendNotification(
              userId: ownerId,
              title: Lang.isSwahili ? 'Agizo Jipya!' : 'New Order!',
              body: '#${order.orderId.substring(0, 8).toUpperCase()}',
              type: 'new_order',
              referenceId: order.orderId,
            );
          }
        }
      } catch (_) {}
      return true;
    } catch (_) { return false; }
  }

  Stream<List<OrderModel>> getAllOrders() =>
      _db.collection('orders').snapshots()
          .map((s) {
            final list = s.docs.map((d) => OrderModel.fromMap(d.data())).toList();
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return list;
          });

  Stream<List<OrderModel>> getShopOwnerOrders(List<String> shopIds) {
    if (shopIds.isEmpty) return Stream.value([]);
    return _db.collection('orders')
        .where('shopId', whereIn: shopIds.take(10).toList())
        .snapshots()
        .map((s) {
          final list = s.docs.map((d) => OrderModel.fromMap(d.data())).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Stream<List<OrderModel>> getCustomerOrders(String customerId) =>
      _db.collection('orders').where('customerId', isEqualTo: customerId)
          .snapshots()
          .map((s) {
            final list = s.docs.map((d) => OrderModel.fromMap(d.data())).toList();
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return list;
          });

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _db.collection('orders').doc(orderId).update({'orderStatus': status});
      return true;
    } catch (_) { return false; }
  }

  Future<bool> assignDeliveryPerson(String orderId, String deliveryPersonId) async {
    try {
      await _db.collection('orders').doc(orderId).update({'deliveryPersonId': deliveryPersonId});
      return true;
    } catch (_) { return false; }
  }

  // ===== DELIVERY =====
  Future<bool> createDelivery(DeliveryModel delivery) async {
    try {
      await _db.collection('deliveries').doc(delivery.deliveryId).set(delivery.toMap());
      return true;
    } catch (_) { return false; }
  }

  Stream<List<DeliveryModel>> getDeliveryPersonOrders(String deliveryPersonId) =>
      _db.collection('deliveries')
          .where('deliveryPersonId', isEqualTo: deliveryPersonId).snapshots()
          .map((s) => s.docs.map((d) => DeliveryModel.fromMap(d.data())).toList());

  Future<bool> updateDeliveryStatus(String deliveryId, String status) async {
    try {
      final Map<String, dynamic> data = {'status': status};
      if (status == 'delivered') {
        data['deliveredAt'] = DateTime.now().toIso8601String();
      }
      await _db.collection('deliveries').doc(deliveryId).update(data);
      return true;
    } catch (_) { return false; }
  }

  // ===== CHAT =====

  /// Tuma ujumbe na uandike metadata kwenye chat doc (kwa lastMessage)
  Future<bool> sendMessage(ChatMessage message) async {
    try {
      final chatId = _chatId(message.senderId, message.receiverId);
      final chatRef = _db.collection('chats').doc(chatId);

      // Hifadhi ujumbe
      await chatRef
          .collection('messages')
          .doc(message.messageId)
          .set(message.toMap());

      // ✅ Andika/update metadata ya chat doc (lastMessage, unreadCount)
      await chatRef.set({
        'participants': [message.senderId, message.receiverId],
        'lastMessage': message.message,
        'lastMessageAt': Timestamp.fromDate(message.createdAt),
        'lastSenderId': message.senderId,
        // Increment unread count kwa receiver
        'unread_${message.receiverId}': FieldValue.increment(1),
      }, SetOptions(merge: true));

      // ✅ Tuma in-app notification kwa receiver
      await sendNotification(
        userId: message.receiverId,
        title: Lang.isSwahili ? 'Ujumbe Mpya' : 'New Message',
        body: message.message.length > 60
            ? '${message.message.substring(0, 60)}...'
            : message.message,
        type: 'chat_message',
        referenceId: message.senderId,
      );

      return true;
    } catch (_) { return false; }
  }

  /// Stream ya messages — inamark kama read mara moja inapofunguliwa
  Stream<List<ChatMessage>> getMessages(String u1, String u2) {
    final chatId = _chatId(u1, u2);
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt') // ✅ Works properly now (Timestamp not String)
        .snapshots()
        .map((s) => s.docs.map((d) => ChatMessage.fromMap(d.data())).toList());
  }

  /// ✅ Stream ya unread count kwa mtumiaji fulani katika mazungumzo
  Stream<int> getUnreadCount(String currentUserId, String otherUserId) {
    final chatId = _chatId(currentUserId, otherUserId);
    return _db.collection('chats').doc(chatId).snapshots().map((doc) {
      if (!doc.exists) return 0;
      final data = doc.data() ?? {};
      return (data['unread_$currentUserId'] as int?) ?? 0;
    });
  }

  /// ✅ Reset unread count baada ya kufungua chat
  Future<void> resetUnreadCount(String currentUserId, String otherUserId) async {
    try {
      final chatId = _chatId(currentUserId, otherUserId);
      await _db.collection('chats').doc(chatId).update({
        'unread_$currentUserId': 0,
      });
    } catch (_) {}
  }

  String _chatId(String u1, String u2) => ([u1, u2]..sort()).join('_');

  /// ✅ Pata users wote waliowahi kuzungumza na admin (real chats only)
  Stream<List<Map<String, dynamic>>> getAdminChatUsers() {
    // ✅ No orderBy — avoids requiring composite Firestore index
    // Sorting is done in Dart after fetching
    return _db
        .collection('chats')
        .where('participants', arrayContains: 'admin')
        .snapshots()
        .map((snap) {
          final docs = snap.docs.map((doc) => {'chatId': doc.id, ...doc.data()}).toList();
          // Sort by lastMessageAt descending in Dart
          docs.sort((a, b) {
            final aTime = a['lastMessageAt'];
            final bTime = b['lastMessageAt'];
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return (bTime as dynamic).compareTo(aTime as dynamic);
          });
          return docs;
        });
  }

  /// Pata mazungumzo yote ambayo admin anayo (legacy — kept for compatibility)
  Stream<List<Map<String, dynamic>>> getAdminConversations() => getAdminChatUsers();

  /// Pata ujumbe wa mwisho wa mazungumzo
  Future<ChatMessage?> getLastMessage(String u1, String u2) async {
    try {
      final chatId = _chatId(u1, u2);
      final snap = await _db
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return ChatMessage.fromMap(snap.docs.first.data());
    } catch (_) { return null; }
  }

  /// Mark all messages from a user as read
  Future<void> markMessagesRead(String senderId, String receiverId) async {
    try {
      final chatId = _chatId(senderId, receiverId);
      final snap = await _db
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isEqualTo: senderId)
          .where('isRead', isEqualTo: false)
          .get();
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (_) {}
  }

  // ===== NOTIFICATIONS =====
  Future<bool> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? referenceId,
  }) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await _db.collection('notifications').doc(id).set(NotificationModel(
        notificationId: id, userId: userId, title: title, body: body,
        type: type, referenceId: referenceId, isRead: false,
        createdAt: DateTime.now(),
      ).toMap());
      return true;
    } catch (_) { return false; }
  }

  Stream<List<NotificationModel>> getUserNotifications(String userId) =>
      _db.collection('notifications').where('userId', isEqualTo: userId).snapshots()
          .map((s) {
            final list = s.docs.map((d) => NotificationModel.fromMap(d.data())).toList();
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return list;
          });

  /// ✅ Merge notifications kwa Firebase UID na 'admin' — kwa admin users
  Stream<List<NotificationModel>> getMergedNotifications(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    // Tumia StreamController kuunganisha streams mbili
    late StreamController<List<NotificationModel>> controller;
    List<NotificationModel> list1 = [];
    List<NotificationModel> list2 = [];
    StreamSubscription? sub1, sub2;

    void emit() {
      final merged = [...list1, ...list2];
      final seen = <String>{};
      final unique = merged.where((n) => seen.add(n.notificationId)).toList();
      unique.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (!controller.isClosed) controller.add(unique);
    }

    controller = StreamController<List<NotificationModel>>(
      onListen: () {
        sub1 = getUserNotifications(userId).listen((data) { list1 = data; emit(); });
        sub2 = getUserNotifications('admin').listen((data) { list2 = data; emit(); });
      },
      onCancel: () { sub1?.cancel(); sub2?.cancel(); },
    );
    return controller.stream;
  }

  /// ✅ Unread notifications count kwa admin — inajumlisha real UID + 'admin'
  Stream<int> getMergedUnreadCount(String userId) {
    late StreamController<int> controller;
    int count1 = 0, count2 = 0;
    StreamSubscription? sub1, sub2;

    controller = StreamController<int>(
      onListen: () {
        sub1 = getUnreadNotificationsCount(userId).listen((c) { count1 = c; if (!controller.isClosed) controller.add(count1 + count2); });
        sub2 = getUnreadNotificationsCount('admin').listen((c) { count2 = c; if (!controller.isClosed) controller.add(count1 + count2); });
      },
      onCancel: () { sub1?.cancel(); sub2?.cancel(); },
    );
    return controller.stream;
  }

  // ✅ Futa notification moja
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).delete();
      return true;
    } catch (_) { return false; }
  }

  // ✅ Futa notifications ZOTE za user
  Future<bool> deleteAllNotifications(String userId) async {
    try {
      final batch = _db.batch();
      // Futa za real UID
      final snap1 = await _db.collection('notifications')
          .where('userId', isEqualTo: userId).get();
      for (final doc in snap1.docs) { batch.delete(doc.reference); }
      // Kama ni admin, futa pia za 'admin'
      final snap2 = await _db.collection('notifications')
          .where('userId', isEqualTo: 'admin').get();
      for (final doc in snap2.docs) { batch.delete(doc.reference); }
      await batch.commit();
      return true;
    } catch (_) { return false; }
  }

  // ✅ Futa message moja ndani ya chat
  Future<bool> deleteMessage(String senderId, String receiverId, String messageId) async {
    try {
      final chatId = _chatId(senderId, receiverId);
      await _db.collection('chats').doc(chatId)
          .collection('messages').doc(messageId).delete();
      return true;
    } catch (_) { return false; }
  }

  Future<bool> markNotificationRead(String id) async {
    try {
      await _db.collection('notifications').doc(id).update({'isRead': true});
      return true;
    } catch (_) { return false; }
  }

  Future<bool> markAllNotificationsRead(String userId) async {
    try {
      final batch = _db.batch();
      final snap = await _db.collection('notifications')
          .where('userId', isEqualTo: userId).get();
      for (final doc in snap.docs) {
        if (doc.data()['isRead'] == false) {
          batch.update(doc.reference, {'isRead': true});
        }
      }
      await batch.commit();
      return true;
    } catch (_) { return false; }
  }

  Stream<int> getUnreadNotificationsCount(String userId) =>
      _db.collection('notifications')
          .where('userId', isEqualTo: userId).snapshots()
          .map((s) => s.docs.where((d) => d.data()['isRead'] == false).length);
}
