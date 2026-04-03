import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../config/lang.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/shop_model.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
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

  void _logout() async {
    await _authService.logout();
    if (!mounted) return;
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
                : _selectedIndex == 3
                ? _buildDeliveryPage()
                : _buildUsersPage(),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          border: Border(top: BorderSide(color: Color(0xFF2A3158), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textGrey,
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
          type: BottomNavigationBarType.fixed,
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
              label: 'Delivery',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people_rounded),
              label: Lang.isSwahili ? 'Watumiaji' : 'Users',
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
                        (b) => const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ).createShader(b),
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
                  GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        ),
                    child: _iconBtn(
                      Icons.notifications_outlined,
                      AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(width: 10),
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
                        border: Border.all(color: const Color(0xFF2A3158)),
                      ),
                      child: Text(
                        Lang.isSwahili ? '🇹🇿' : '🇬🇧',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
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
          Text(
            Lang.isSwahili ? 'Muhtasari' : 'Overview',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 14),
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
            title: Lang.isSwahili ? 'Simamia Watumiaji' : 'Manage Users',
            icon: Icons.people_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF00D68F), Color(0xFF00A86B)],
            ),
            onTap: () => setState(() => _selectedIndex = 4),
            fullWidth: true,
          ),
          const SizedBox(height: 24),
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
              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return _buildEmptyState(
                  Lang.isSwahili ? 'Hakuna maagizo bado' : 'No orders yet',
                );
              final orders = snapshot.data!.take(5).toList();
              return Column(
                children: orders.map((o) => _buildOrderTile(o)).toList(),
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
              GestureDetector(
                onTap: _showAddShopDialog,
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
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return _buildEmptyState(
                  Lang.isSwahili ? 'Hakuna maduka bado' : 'No shops yet',
                );
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: snapshot.data!.length,
                itemBuilder: (_, i) => _buildShopTile(snapshot.data![i]),
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
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return _buildEmptyState(
                  Lang.isSwahili ? 'Hakuna maagizo bado' : 'No orders yet',
                );
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: snapshot.data!.length,
                itemBuilder: (_, i) => _buildOrderCard(snapshot.data![i]),
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
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return _buildEmptyState(
                  Lang.isSwahili
                      ? 'Hakuna deliveries bado'
                      : 'No deliveries yet',
                );
              final active =
                  snapshot.data!
                      .where(
                        (o) =>
                            o.orderStatus == 'confirmed' ||
                            o.orderStatus == 'picked_up' ||
                            o.orderStatus == 'on_the_way' ||
                            o.orderStatus == 'delivered',
                      )
                      .toList();
              if (active.isEmpty)
                return _buildEmptyState(
                  Lang.isSwahili
                      ? 'Hakuna deliveries zinazoendelea'
                      : 'No active deliveries',
                );
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: active.length,
                itemBuilder: (_, i) => _buildDeliveryOrderCard(active[i]),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== USERS PAGE ====================
  Widget _buildUsersPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            Lang.isSwahili ? 'Watumiaji Wote' : 'All Users',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textWhite,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<UserModel>>(
            stream: _firestoreService.getAllUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return _buildEmptyState(
                  Lang.isSwahili ? 'Hakuna watumiaji' : 'No users found',
                );
              // Sort: admins first, then shop_owner, delivery, customer
              final users = snapshot.data!;
              users.sort((a, b) {
                const order = ['admin', 'shop_owner', 'delivery', 'customer'];
                return order.indexOf(a.role).compareTo(order.indexOf(b.role));
              });
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: users.length,
                itemBuilder: (_, i) => _buildUserTile(users[i]),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== WIDGETS ====================

  Widget _iconBtn(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFF2A3158)),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

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
          count =
              filterStatus != null
                  ? data
                      .where(
                        (item) =>
                            item.status == filterStatus ||
                            item.orderStatus == filterStatus,
                      )
                      .length
                  : data.length;
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF2A3158)),
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

  Widget _buildOrderTile(dynamic order) {
    Color statusColor = AppColors.warning;
    if (order.orderStatus == 'delivered') statusColor = AppColors.success;
    if (order.orderStatus == 'confirmed') statusColor = AppColors.primary;
    if (order.orderStatus == 'cancelled') statusColor = AppColors.error;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A3158)),
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
                  '#${order.orderId.substring(0, 8).toUpperCase()}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                ),
                Text(
                  order.paymentMethod.toUpperCase(),
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
                'TSh ${order.totalAmount.toStringAsFixed(0)}',
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
                  order.orderStatus.toUpperCase(),
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
        border: Border.all(color: const Color(0xFF2A3158)),
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
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
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

  Widget _buildShopTile(ShopModel shop) {
    Color statusColor = AppColors.warning;
    if (shop.status == 'active') statusColor = AppColors.success;
    if (shop.status == 'suspended') statusColor = AppColors.error;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3158)),
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
              if (shop.status != 'active') const SizedBox(width: 8),
              if (shop.status != 'suspended')
                Expanded(
                  child: _buildActionButton(
                    label: Lang.isSwahili ? 'Simamisha' : 'Suspend',
                    color: AppColors.warning,
                    onTap:
                        () => _firestoreService.updateShopStatus(
                          shop.shopId,
                          'suspended',
                        ),
                  ),
                ),
              const SizedBox(width: 8),
              // Delete shop + all its products
              GestureDetector(
                onTap: () => _confirmDeleteShop(shop),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.delete_rounded,
                        color: AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Lang.isSwahili ? 'Futa' : 'Delete',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ],
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
        border: Border.all(color: const Color(0xFF2A3158)),
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
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusLabel.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.secondary,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.deliveryAddress.isNotEmpty
                      ? order.deliveryAddress
                      : 'Tanzania',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
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
          if (order.deliveryPersonId != null &&
              order.deliveryPersonId!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.delivery_dining_rounded,
                  color: AppColors.primary,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  Lang.isSwahili
                      ? 'Msafirishaji amekabidhiwa'
                      : 'Delivery person assigned',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          if (order.orderStatus != 'delivered') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (order.orderStatus == 'confirmed')
                  Expanded(
                    child: _buildActionButton(
                      label: 'Picked Up',
                      color: AppColors.info,
                      onTap:
                          () => _firestoreService.updateOrderStatus(
                            order.orderId,
                            'picked_up',
                          ),
                    ),
                  ),
                if (order.orderStatus == 'picked_up')
                  Expanded(
                    child: _buildActionButton(
                      label: 'On The Way',
                      color: AppColors.primary,
                      onTap:
                          () => _firestoreService.updateOrderStatus(
                            order.orderId,
                            'on_the_way',
                          ),
                    ),
                  ),
                if (order.orderStatus == 'on_the_way')
                  Expanded(
                    child: _buildActionButton(
                      label: 'Delivered',
                      color: AppColors.success,
                      onTap:
                          () => _firestoreService.updateOrderStatus(
                            order.orderId,
                            'delivered',
                          ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    // Role color & icon
    Color roleColor;
    IconData roleIcon;
    String roleLabel;
    switch (user.role) {
      case 'admin':
        roleColor = AppColors.primary;
        roleIcon = Icons.admin_panel_settings_rounded;
        roleLabel = 'Admin';
        break;
      case 'shop_owner':
        roleColor = AppColors.secondary;
        roleIcon = Icons.store_rounded;
        roleLabel = Lang.isSwahili ? 'Mwenye Duka' : 'Shop Owner';
        break;
      case 'delivery':
        roleColor = AppColors.success;
        roleIcon = Icons.delivery_dining_rounded;
        roleLabel = Lang.isSwahili ? 'Msafirishaji' : 'Delivery';
        break;
      default:
        roleColor = AppColors.info;
        roleIcon = Icons.person_rounded;
        roleLabel = Lang.isSwahili ? 'Mnunuzi' : 'Customer';
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3158)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(roleIcon, color: roleColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                ),
                Text(
                  user.email,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.phone,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  roleLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: roleColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Don't show delete for admin
              if (user.role != 'admin')
                GestureDetector(
                  onTap: () => _confirmDeleteUser(user),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          Lang.isSwahili ? 'Futa' : 'Delete',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
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
          border: Border.all(color: color.withValues(alpha: 0.3)),
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

  // ==================== DIALOGS ====================

  void _confirmDeleteShop(ShopModel shop) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppColors.bgCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              Lang.isSwahili ? 'Futa Duka?' : 'Delete Shop?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: AppColors.textWhite,
              ),
            ),
            content: Text(
              Lang.isSwahili
                  ? 'Kufuta "${shop.name}" kutafuta pia bidhaa zake zote. Hii haiwezi kurudishwa!'
                  : 'Deleting "${shop.name}" will also delete all its products. This cannot be undone!',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  Lang.get('cancel'),
                  style: GoogleFonts.poppins(color: AppColors.textGrey),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await _firestoreService.deleteShopCascade(shop.shopId);
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        Lang.isSwahili ? 'Duka limefutwa!' : 'Shop deleted!',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    Lang.get('delete'),
                    style: GoogleFonts.poppins(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _confirmDeleteUser(UserModel user) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppColors.bgCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              Lang.isSwahili ? 'Futa Mtumiaji?' : 'Delete User?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: AppColors.textWhite,
              ),
            ),
            content: Text(
              Lang.isSwahili
                  ? 'Una uhakika unataka kufuta "${user.name}"? Hii haiwezi kurudishwa!'
                  : 'Are you sure you want to delete "${user.name}"? This cannot be undone!',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  Lang.get('cancel'),
                  style: GoogleFonts.poppins(color: AppColors.textGrey),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await _firestoreService.deleteUserFromFirestore(user.uid);
                  // If shop_owner, delete their shops and products too
                  if (user.role == 'shop_owner') {
                    final shops =
                        await _firestoreService.getMyShops(user.uid).first;
                    for (final shop in shops) {
                      await _firestoreService.deleteShopCascade(shop.shopId);
                    }
                  }
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        Lang.isSwahili ? 'Mtumiaji amefutwa!' : 'User deleted!',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    Lang.get('delete'),
                    style: GoogleFonts.poppins(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
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
                            border: Border.all(color: const Color(0xFF2A3158)),
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
                        if (nameController.text.isEmpty) return;
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
                        if (!context.mounted) return;
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
