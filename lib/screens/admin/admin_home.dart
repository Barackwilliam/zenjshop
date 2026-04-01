import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../config/lang.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/shop_model.dart';
import '../../models/order_model.dart';
import '../notifications/notifications_screen.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  int _selectedIndex = 0;


  @override
  void initState() {
    super.initState();
  }

  void _logout() async {
    await _authService.logout();
    if (!mounted) { return; }
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child:
            _selectedIndex == 0
                ? _buildDashboard()
                : _selectedIndex == 1
                ? _buildShopsPage()
                : _selectedIndex == 2
                ? _buildOrdersPage()
                : _buildDeliveryPage(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: Border(
            top: BorderSide(color: const Color(0xFF2A3158), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_rounded),
              label: Lang.isSwahili ? 'Dashibodi' : 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.store_rounded),
              label: Lang.isSwahili ? 'Maduka' : 'Shops',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_rounded),
              label: Lang.isSwahili ? 'Maagizo' : 'Orders',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.delivery_dining_rounded),
              label: Lang.isSwahili ? 'Delivery' : 'Delivery',
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DASHBOARD ====================
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Lang.isSwahili ? 'Habari,' : 'Hello,',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback:
                        (bounds) => const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ).createShader(bounds),
                    child: Text(
                      'Admin ZenjShop',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Notification
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: const Color(0xFF2A3158),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.textGrey,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // Language Toggle
                  GestureDetector(
                    onTap: () => setState(() => Lang.toggle()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: const Color(0xFF2A3158),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        Lang.isSwahili ? '🇹🇿' : '🇬🇧',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Logout
                  GestureDetector(
                    onTap: _logout,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stats Cards
          Text(
            Lang.isSwahili ? 'Muhtasari' : 'Overview',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 14),

          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard(
                title: Lang.get('total_orders'),
                icon: Icons.receipt_long_rounded,
                color: AppColors.primary,
                stream: _firestoreService.getAllOrders(),
              ),
              _buildStatCard(
                title: Lang.get('total_shops'),
                icon: Icons.store_rounded,
                color: AppColors.secondary,
                stream: _firestoreService.getAllShops(),
              ),
              _buildStatCard(
                title: Lang.get('pending_orders'),
                icon: Icons.pending_actions_rounded,
                color: AppColors.warning,
                stream: _firestoreService.getAllOrders(),
                filterStatus: 'pending',
              ),
              _buildStatCard(
                title: Lang.isSwahili ? 'Watumiaji Wote' : 'Total Users',
                icon: Icons.people_rounded,
                color: AppColors.info,
                stream: _firestoreService.getAllUsers(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Text(
            Lang.isSwahili ? 'Vitendo vya Haraka' : 'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  title: Lang.get('manage_shops'),
                  icon: Icons.store_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4B44CC)],
                  ),
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildActionCard(
                  title: Lang.get('manage_orders'),
                  icon: Icons.receipt_long_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF9A3C)],
                  ),
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildActionCard(
            title: Lang.get('manage_delivery'),
            icon: Icons.delivery_dining_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF00D68F), Color(0xFF00A86B)],
            ),
            onTap: () => setState(() => _selectedIndex = 3),
            fullWidth: true,
          ),

          const SizedBox(height: 24),

          // Recent Orders
          Text(
            Lang.isSwahili ? 'Maagizo ya Hivi Karibuni' : 'Recent Orders',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 14),

          StreamBuilder(
            stream: _firestoreService.getAllOrders(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState(
                  Lang.isSwahili ? 'Hakuna maagizo bado' : 'No orders yet',
                );
              }
              final orders = snapshot.data!.take(5).toList();
              return Column(
                children:
                    orders.map((order) {
                      return _buildOrderTile(
                        orderId: order.orderId,
                        status: order.orderStatus,
                        amount: order.totalAmount,
                        payment: order.paymentMethod,
                      );
                    }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== SHOPS PAGE ====================
  Widget _buildShopsPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Lang.get('manage_shops'),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textWhite,
                ),
              ),
              // Add Shop Button
              GestureDetector(
                onTap: () => _showAddShopDialog(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        Lang.isSwahili ? 'Ongeza' : 'Add',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: _firestoreService.getAllShops(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState(
                  Lang.isSwahili ? 'Hakuna maduka bado' : 'No shops yet',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final shop = snapshot.data![index];
                  return _buildShopTile(shop);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== ORDERS PAGE ====================
  Widget _buildOrdersPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            Lang.get('manage_orders'),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textWhite,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: _firestoreService.getAllOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState(
                  Lang.isSwahili ? 'Hakuna maagizo bado' : 'No orders yet',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final order = snapshot.data![index];
                  return _buildOrderCard(order);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== DELIVERY PAGE ====================
  Widget _buildDeliveryPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            Lang.get('manage_delivery'),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textWhite,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<OrderModel>>(
            stream: _firestoreService.getAllOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState(
                  Lang.isSwahili
                      ? 'Hakuna deliveries bado'
                      : 'No deliveries yet',
                );
              }
              // Confirmed orders zinazosubiri msafirishaji + zinazoendelea
              final activeOrders = snapshot.data!
                  .where((o) =>
                      o.orderStatus == 'confirmed' ||
                      o.orderStatus == 'picked_up' ||
                      o.orderStatus == 'on_the_way' ||
                      o.orderStatus == 'delivered')
                  .toList();
              if (activeOrders.isEmpty) {
                return _buildEmptyState(
                  Lang.isSwahili
                      ? 'Hakuna deliveries zinazoendelea'
                      : 'No active deliveries',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: activeOrders.length,
                itemBuilder: (context, index) {
                  return _buildDeliveryOrderCard(activeOrders[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== WIDGETS ====================

  Widget _buildStatCard({
    required String title,
    required IconData icon,
    required Color color,
    required Stream stream,
    String? filterStatus,
  }) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) {
          final data = snapshot.data as List;
          if (filterStatus != null) {
            count =
                data
                    .where(
                      (item) =>
                          item.status == filterStatus ||
                          item.orderStatus == filterStatus,
                    )
                    .length;
          } else {
            count = data.length;
          }
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF2A3158), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textWhite,
                    ),
                  ),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTile({
    required String orderId,
    required String status,
    required double amount,
    required String payment,
  }) {
    Color statusColor = AppColors.warning;
    if (status == 'delivered') statusColor = AppColors.success;
    if (status == 'confirmed') statusColor = AppColors.primary;
    if (status == 'cancelled') statusColor = AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A3158), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${orderId.substring(0, 8).toUpperCase()}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                ),
                Text(
                  payment.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TSh ${amount.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textWhite,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    Color statusColor = AppColors.warning;
    if (order.orderStatus == 'delivered') statusColor = AppColors.success;
    if (order.orderStatus == 'confirmed') statusColor = AppColors.primary;
    if (order.orderStatus == 'cancelled') statusColor = AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3158), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.orderId.substring(0, 8).toUpperCase()}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textWhite,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  order.orderStatus.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                color: AppColors.textGrey,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'TSh ${order.totalAmount.toStringAsFixed(0)} • ${order.paymentMethod.toUpperCase()}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Action Buttons
          Row(
            children: [
              if (order.orderStatus == 'pending')
                Expanded(
                  child: _buildActionButton(
                    label: Lang.isSwahili ? 'Thibitisha' : 'Confirm',
                    color: AppColors.success,
                    onTap:
                        () => _firestoreService.updateOrderStatus(
                          order.orderId,
                          'confirmed',
                        ),
                  ),
                ),
              if (order.orderStatus == 'pending') const SizedBox(width: 10),
              if (order.orderStatus != 'delivered' &&
                  order.orderStatus != 'cancelled')
                Expanded(
                  child: _buildActionButton(
                    label: Lang.isSwahili ? 'Ghairi' : 'Cancel',
                    color: AppColors.error,
                    onTap:
                        () => _firestoreService.updateOrderStatus(
                          order.orderId,
                          'cancelled',
                        ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShopTile(dynamic shop) {
    Color statusColor = AppColors.warning;
    if (shop.status == 'active') statusColor = AppColors.success;
    if (shop.status == 'suspended') statusColor = AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3158), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.store_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textWhite,
                      ),
                    ),
                    Text(
                      shop.category,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  shop.status.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (shop.status != 'active')
                Expanded(
                  child: _buildActionButton(
                    label: Lang.isSwahili ? 'Idhinisha' : 'Approve',
                    color: AppColors.success,
                    onTap:
                        () => _firestoreService.updateShopStatus(
                          shop.shopId,
                          'active',
                        ),
                  ),
                ),
              if (shop.status != 'active') const SizedBox(width: 10),
              if (shop.status != 'suspended')
                Expanded(
                  child: _buildActionButton(
                    label: Lang.isSwahili ? 'Simamisha' : 'Suspend',
                    color: AppColors.error,
                    onTap:
                        () => _firestoreService.updateShopStatus(
                          shop.shopId,
                          'suspended',
                        ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildDeliveryOrderCard(OrderModel order) {
    Color statusColor = AppColors.warning;
    String statusLabel = 'Confirmed';
    if (order.orderStatus == 'picked_up') {
      statusColor = AppColors.info;
      statusLabel = 'Picked Up';
    } else if (order.orderStatus == 'on_the_way') {
      statusColor = AppColors.primary;
      statusLabel = 'On The Way';
    } else if (order.orderStatus == 'delivered') {
      statusColor = AppColors.success;
      statusLabel = 'Delivered';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3158), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#\${order.orderId.substring(0, 8).toUpperCase()}',
                style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textWhite),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
                ),
                child: Text(statusLabel.toUpperCase(),
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.secondary, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.deliveryAddress.isNotEmpty ? order.deliveryAddress : 'Tanzania',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.payments_outlined, color: AppColors.textGrey, size: 14),
              const SizedBox(width: 6),
              Text('TSh \${order.totalAmount.toStringAsFixed(0)} • \${order.paymentMethod.toUpperCase()}',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
            ],
          ),
          if (order.deliveryPersonId != null && order.deliveryPersonId!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.delivery_dining_rounded, color: AppColors.primary, size: 14),
                const SizedBox(width: 6),
                Text('Msafirishaji amekabidhiwa',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
          if (order.orderStatus != 'delivered') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (order.orderStatus == 'confirmed')
                  Expanded(child: _buildActionButton(
                    label: 'Picked Up', color: AppColors.info,
                    onTap: () => _firestoreService.updateOrderStatus(order.orderId, 'picked_up'),
                  )),
                if (order.orderStatus == 'picked_up')
                  Expanded(child: _buildActionButton(
                    label: 'On The Way', color: AppColors.primary,
                    onTap: () => _firestoreService.updateOrderStatus(order.orderId, 'on_the_way'),
                  )),
                if (order.orderStatus == 'on_the_way')
                  Expanded(child: _buildActionButton(
                    label: 'Delivered', color: AppColors.success,
                    onTap: () => _firestoreService.updateOrderStatus(order.orderId, 'delivered'),
                  )),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            color: AppColors.textGrey.withValues(alpha: 0.4),
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  void _showAddShopDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    String selectedCategory = 'Electronics';

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  backgroundColor: AppColors.bgCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    Lang.isSwahili ? 'Ongeza Duka' : 'Add Shop',
                    style: GoogleFonts.poppins(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          style: GoogleFonts.poppins(
                            color: AppColors.textWhite,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                Lang.isSwahili ? 'Jina la Duka' : 'Shop Name',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descController,
                          style: GoogleFonts.poppins(
                            color: AppColors.textWhite,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                Lang.isSwahili ? 'Maelezo' : 'Description',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: locationController,
                          style: GoogleFonts.poppins(
                            color: AppColors.textWhite,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: Lang.isSwahili ? 'Mahali' : 'Location',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.bgSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF2A3158),
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedCategory,
                              dropdownColor: AppColors.bgCard,
                              items:
                                  [
                                        'Electronics',
                                        'Clothing',
                                        'Food',
                                        'Beauty',
                                        'Home',
                                        'Sports',
                                        'Other',
                                      ]
                                      .map(
                                        (cat) => DropdownMenuItem(
                                          value: cat,
                                          child: Text(
                                            cat,
                                            style: GoogleFonts.poppins(
                                              color: AppColors.textWhite,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (val) => setDialogState(
                                    () => selectedCategory = val!,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        Lang.get('cancel'),
                        style: GoogleFonts.poppins(color: AppColors.textGrey),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (nameController.text.isEmpty) { return; }
                        final shopId =
                            DateTime.now().millisecondsSinceEpoch.toString();
                        await _firestoreService.addShop(
                          ShopModel(
                            shopId: shopId,
                            name: nameController.text.trim(),
                            description: descController.text.trim(),
                            category: selectedCategory,
                            location: locationController.text.trim(),
                            ownerId: 'admin',
                            status: 'active',
                            createdAt: DateTime.now(),
                          ),
                        );
                        if (!context.mounted) { return; }
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          Lang.get('save'),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }
}
