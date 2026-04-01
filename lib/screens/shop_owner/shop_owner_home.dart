import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../config/lang.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/shop_model.dart';
import '../../models/product_model.dart';
import '../../models/order_model.dart';

import '../notifications/notifications_screen.dart';

class ShopOwnerHome extends StatefulWidget {
  const ShopOwnerHome({super.key});

  @override
  State<ShopOwnerHome> createState() => _ShopOwnerHomeState();
}

class _ShopOwnerHomeState extends State<ShopOwnerHome> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  int _selectedIndex = 0;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _authService.currentUser?.uid;
  }

  void _logout() async {
    await _authService.logout();
    if (!mounted) { return; }
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: _selectedIndex == 0
            ? _buildDashboard(isDark)
            : _selectedIndex == 1
                ? _buildShopsTab(isDark)
                : _selectedIndex == 2
                    ? _buildOrdersTab(isDark)
                    : _buildProfileTab(isDark, themeProvider),
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  // ==================== DASHBOARD ====================
  Widget _buildDashboard(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
                      fontSize: 13,
                      color: isDark ? AppColors.textGrey : AppColors.textDarkGrey,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ).createShader(bounds),
                    child: Text(
                      Lang.isSwahili ? 'Duka Langu' : 'My Shop',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Notification button na badge ya unread count
                  StreamBuilder<int>(
                    stream: _firestoreService.getUnreadNotificationsCount(
                        _currentUserId ?? ''),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const NotificationsScreen())),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 1),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.notifications_outlined,
                                  color: AppColors.primary, size: 20),
                              if (count > 0)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  // Logout button
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
                      child: const Icon(Icons.logout_rounded,
                          color: AppColors.error, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stats — inatumia maduka ya owner na orders za maduka yake
          StreamBuilder<List<ShopModel>>(
            stream: _firestoreService.getMyShops(_currentUserId ?? ''),
            builder: (context, shopSnapshot) {
              final shops = shopSnapshot.data ?? [];
              final shopIds = shops.map((s) => s.shopId).toList();

              return StreamBuilder<List<OrderModel>>(
                stream: _firestoreService.getShopOwnerOrders(shopIds),
                builder: (context, orderSnapshot) {
                  final orders = orderSnapshot.data ?? [];
                  final pending =
                      orders.where((o) => o.orderStatus == 'pending').length;
                  final completed =
                      orders.where((o) => o.orderStatus == 'delivered').length;

                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.4,
                    children: [
                      _buildStatCard(
                        title: Lang.isSwahili ? 'Maduka Yangu' : 'My Shops',
                        value: '${shops.length}',
                        icon: Icons.store_rounded,
                        color: AppColors.primary,
                        isDark: isDark,
                      ),
                      _buildStatCard(
                        title: Lang.isSwahili ? 'Maagizo Yote' : 'Total Orders',
                        value: '${orders.length}',
                        icon: Icons.receipt_long_rounded,
                        color: AppColors.secondary,
                        isDark: isDark,
                      ),
                      _buildStatCard(
                        title: Lang.isSwahili ? 'Yanayosubiri' : 'Pending',
                        value: '$pending',
                        icon: Icons.pending_actions_rounded,
                        color: AppColors.warning,
                        isDark: isDark,
                      ),
                      _buildStatCard(
                        title: Lang.isSwahili ? 'Zilizokamilika' : 'Completed',
                        value: '$completed',
                        icon: Icons.check_circle_rounded,
                        color: AppColors.success,
                        isDark: isDark,
                      ),
                    ],
                  );
                },
              );
            },
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Text(
            Lang.isSwahili ? 'Vitendo vya Haraka' : 'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  title: Lang.isSwahili ? 'Ongeza Duka' : 'Add Shop',
                  icon: Icons.add_business_rounded,
                  gradient: AppColors.primaryGradient,
                  onTap: () => _showAddShopDialog(isDark),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildActionCard(
                  title: Lang.isSwahili ? 'Ona Maagizo' : 'View Orders',
                  icon: Icons.receipt_long_rounded,
                  gradient: AppColors.orangeGradient,
                  onTap: () => setState(() => _selectedIndex = 2),
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Orders — za maduka ya owner tu
          Text(
            Lang.isSwahili ? 'Maagizo ya Hivi Karibuni' : 'Recent Orders',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),

          StreamBuilder<List<ShopModel>>(
            stream: _firestoreService.getMyShops(_currentUserId ?? ''),
            builder: (context, shopSnapshot) {
              final shopIds =
                  (shopSnapshot.data ?? []).map((s) => s.shopId).toList();
              return StreamBuilder<List<OrderModel>>(
                stream: _firestoreService.getShopOwnerOrders(shopIds),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState(
                      Lang.isSwahili
                          ? 'Hakuna maagizo bado'
                          : 'No orders yet',
                      isDark,
                    );
                  }
                  final orders = snapshot.data!.take(5).toList();
                  return Column(
                    children: orders
                        .map((o) => _buildOrderTile(o, isDark))
                        .toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== SHOPS TAB ====================
  Widget _buildShopsTab(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Lang.isSwahili ? 'Maduka Yangu' : 'My Shops',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textWhite : AppColors.textDark,
                ),
              ),
              GestureDetector(
                onTap: () => _showAddShopDialog(isDark),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
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
          child: StreamBuilder<List<ShopModel>>(
            stream: _firestoreService.getMyShops(_currentUserId ?? ''),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState(
                  Lang.isSwahili
                      ? 'Huna maduka bado.\nBonyeza + kuongeza!'
                      : 'No shops yet.\nTap + to add one!',
                  isDark,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final shop = snapshot.data![index];
                  return _buildShopTile(shop, isDark);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== ORDERS TAB ====================
  Widget _buildOrdersTab(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            Lang.isSwahili ? 'Maagizo Yangu' : 'My Orders',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : AppColors.textDark,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ShopModel>>(
            stream: _firestoreService.getMyShops(_currentUserId ?? ''),
            builder: (context, shopSnapshot) {
              final shopIds =
                  (shopSnapshot.data ?? []).map((s) => s.shopId).toList();
              return StreamBuilder<List<OrderModel>>(
                stream: _firestoreService.getShopOwnerOrders(shopIds),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState(
                      Lang.isSwahili
                          ? 'Hakuna maagizo bado'
                          : 'No orders yet',
                      isDark,
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(snapshot.data![index], isDark);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== PROFILE TAB ====================
  Widget _buildProfileTab(bool isDark, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.store_rounded,
                color: Colors.white, size: 44),
          ),
          const SizedBox(height: 16),
          Text(
            Lang.isSwahili ? 'Mwenye Duka' : 'Shop Owner',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _authService.currentUser?.email ?? '',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? AppColors.textGrey : AppColors.textDarkGrey,
            ),
          ),
          const SizedBox(height: 32),

          _buildSettingsTile(
            icon: Icons.dark_mode_rounded,
            title: Lang.isSwahili ? 'Hali ya Giza' : 'Dark Mode',
            isDark: isDark,
            trailing: Switch(
              value: isDark,
              onChanged: (_) => themeProvider.toggleTheme(),
              activeColor: AppColors.primary,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.language_rounded,
            title: Lang.isSwahili ? 'Lugha' : 'Language',
            isDark: isDark,
            trailing: GestureDetector(
              onTap: () => setState(() => Lang.toggle()),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  Lang.isSwahili ? '🇹🇿 SW' : '🇬🇧 EN',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: Lang.isSwahili ? 'Arifa' : 'Notifications',
            isDark: isDark,
            trailing: GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen())),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.primary, size: 16),
            ),
          ),

          const SizedBox(height: 10),

          GestureDetector(
            onTap: _logout,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded,
                      color: AppColors.error, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    Lang.get('logout'),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
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
    );
  }

  // ==================== WIDGETS ====================

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
          width: 1,
        ),
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
                value,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textWhite : AppColors.textDark,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: isDark ? AppColors.textGrey : AppColors.textDarkGrey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopTile(ShopModel shop, bool isDark) {
    Color statusColor = AppColors.warning;
    if (shop.status == 'active') statusColor = AppColors.success;
    if (shop.status == 'suspended') statusColor = AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.store_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? AppColors.textWhite : AppColors.textDark,
                      ),
                    ),
                    Text(
                      shop.category,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textGrey
                            : AppColors.textDarkGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          // Add Product Button
          GestureDetector(
            onTap: () => _showAddProductDialog(shop.shopId, isDark),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    Lang.isSwahili ? 'Ongeza Bidhaa' : 'Add Product',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Products List na delete button
          StreamBuilder<List<ProductModel>>(
            stream: _firestoreService.getShopProducts(shop.shopId),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text(
                  Lang.isSwahili ? 'Hakuna bidhaa bado' : 'No products yet',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color:
                        isDark ? AppColors.textGrey : AppColors.textDarkGrey,
                  ),
                );
              }
              return Column(
                children: snapshot.data!
                    .map((p) => _buildProductTile(p, isDark))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(ProductModel product, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgSurface : AppColors.bgSurfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                color: AppColors.secondary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textWhite : AppColors.textDark,
                  ),
                ),
                Text(
                  'TSh ${product.price.toStringAsFixed(0)} • Stock: ${product.stock}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Toggle availability
          GestureDetector(
            onTap: () => _firestoreService.updateProductAvailability(
                product.productId, !product.isAvailable),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: product.isAvailable
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                product.isAvailable ? 'ON' : 'OFF',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: product.isAvailable
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Delete product
          GestureDetector(
            onTap: () => _confirmDeleteProduct(product, isDark),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTile(OrderModel order, bool isDark) {
    Color statusColor = AppColors.warning;
    if (order.orderStatus == 'delivered') statusColor = AppColors.success;
    if (order.orderStatus == 'confirmed') statusColor = AppColors.primary;
    if (order.orderStatus == 'cancelled') statusColor = AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
          width: 1,
        ),
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
            child: const Icon(Icons.receipt_rounded,
                color: AppColors.primary, size: 20),
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
                    color: isDark ? AppColors.textWhite : AppColors.textDark,
                  ),
                ),
                Text(
                  'TSh ${order.totalAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textGrey
                        : AppColors.textDarkGrey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }

  Widget _buildOrderCard(OrderModel order, bool isDark) {
    Color statusColor = AppColors.warning;
    if (order.orderStatus == 'delivered') statusColor = AppColors.success;
    if (order.orderStatus == 'confirmed') statusColor = AppColors.primary;
    if (order.orderStatus == 'picked_up') statusColor = AppColors.info;
    if (order.orderStatus == 'on_the_way') statusColor = AppColors.info;
    if (order.orderStatus == 'cancelled') statusColor = AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
          width: 1,
        ),
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
                  color: isDark ? AppColors.textWhite : AppColors.textDark,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.3), width: 1),
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
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.payments_outlined,
                  color: AppColors.textGrey, size: 14),
              const SizedBox(width: 6),
              Text(
                'TSh ${order.totalAmount.toStringAsFixed(0)} • ${order.paymentMethod.toUpperCase()}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textGrey
                      : AppColors.textDarkGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.secondary, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textGrey
                        : AppColors.textDarkGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Items ya order
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              order.items
                  .map((i) => '${i['name']} x${i['quantity']}')
                  .take(2)
                  .join(', '),
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isDark ? AppColors.textGrey : AppColors.textDarkGrey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            color: isDark
                ? AppColors.textGrey.withValues(alpha: 0.3)
                : AppColors.textDarkGrey.withValues(alpha: 0.3),
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? AppColors.textGrey : AppColors.textDarkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required bool isDark,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textWhite : AppColors.textDark,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor:
            isDark ? AppColors.textGrey : AppColors.textDarkGrey,
        selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard_rounded),
            label: Lang.isSwahili ? 'Dashibodi' : 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.store_outlined),
            activeIcon: const Icon(Icons.store_rounded),
            label: Lang.isSwahili ? 'Maduka' : 'Shops',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long_rounded),
            label: Lang.isSwahili ? 'Maagizo' : 'Orders',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outlined),
            activeIcon: const Icon(Icons.person_rounded),
            label: Lang.isSwahili ? 'Wasifu' : 'Profile',
          ),
        ],
      ),
    );
  }

  // ==================== DIALOGS ====================

  void _confirmDeleteProduct(ProductModel product, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          Lang.isSwahili ? 'Futa Bidhaa?' : 'Delete Product?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : AppColors.textDark,
          ),
        ),
        content: Text(
          Lang.isSwahili
              ? 'Una uhakika unataka kufuta "${product.name}"?'
              : 'Are you sure you want to delete "${product.name}"?',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isDark ? AppColors.textGrey : AppColors.textDarkGrey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(Lang.get('cancel'),
                style: GoogleFonts.poppins(color: AppColors.textGrey)),
          ),
          GestureDetector(
            onTap: () async {
              await _firestoreService.deleteProduct(product.productId);
              if (!ctx.mounted) { return; }
              Navigator.pop(ctx);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  void _showAddShopDialog(bool isDark) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    String selectedCategory = 'Electronics';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.bgCard : AppColors.bgCardLight,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: Text(
            Lang.isSwahili ? 'Ongeza Duka' : 'Add Shop',
            style: GoogleFonts.poppins(
              color: isDark ? AppColors.textWhite : AppColors.textDark,
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
                    color: isDark ? AppColors.textWhite : AppColors.textDark,
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
                    color: isDark ? AppColors.textWhite : AppColors.textDark,
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
                    color: isDark ? AppColors.textWhite : AppColors.textDark,
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
                    color: isDark
                        ? AppColors.bgSurface
                        : AppColors.bgSurfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2A3158)
                          : const Color(0xFFDDE0FF),
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedCategory,
                      dropdownColor: isDark
                          ? AppColors.bgCard
                          : AppColors.bgCardLight,
                      items: [
                        'Electronics',
                        'Clothing',
                        'Food',
                        'Beauty',
                        'Home',
                        'Sports',
                        'Other',
                      ]
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(
                                  cat,
                                  style: GoogleFonts.poppins(
                                    color: isDark
                                        ? AppColors.textWhite
                                        : AppColors.textDark,
                                    fontSize: 14,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setDialogState(() => selectedCategory = val!),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(Lang.get('cancel'),
                  style:
                      GoogleFonts.poppins(color: AppColors.textGrey)),
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
                    ownerId: _currentUserId ?? '',
                    status: 'pending',
                    createdAt: DateTime.now(),
                  ),
                );
                if (!context.mounted) { return; }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      Lang.isSwahili
                          ? 'Duka limewasilishwa kwa admin kuidhinishwa'
                          : 'Shop submitted for admin approval',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    backgroundColor: AppColors.warning,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
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

  void _showAddProductDialog(String shopId, bool isDark) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    final stockController = TextEditingController();
    String selectedCategory = 'Electronics';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.bgCard : AppColors.bgCardLight,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: Text(
            Lang.isSwahili ? 'Ongeza Bidhaa' : 'Add Product',
            style: GoogleFonts.poppins(
              color: isDark ? AppColors.textWhite : AppColors.textDark,
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
                    color: isDark ? AppColors.textWhite : AppColors.textDark,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: Lang.isSwahili
                        ? 'Jina la Bidhaa'
                        : 'Product Name',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(
                    color: isDark ? AppColors.textWhite : AppColors.textDark,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: Lang.isSwahili ? 'Bei (TSh)' : 'Price (TSh)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  style: GoogleFonts.poppins(
                    color: isDark ? AppColors.textWhite : AppColors.textDark,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        Lang.isSwahili ? 'Maelezo' : 'Description',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(
                    color: isDark ? AppColors.textWhite : AppColors.textDark,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: Lang.isSwahili ? 'Idadi' : 'Stock',
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.bgSurface
                        : AppColors.bgSurfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2A3158)
                          : const Color(0xFFDDE0FF),
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedCategory,
                      dropdownColor: isDark
                          ? AppColors.bgCard
                          : AppColors.bgCardLight,
                      items: [
                        'Electronics',
                        'Clothing',
                        'Food',
                        'Beauty',
                        'Home',
                        'Sports',
                        'Other',
                      ]
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(
                                  cat,
                                  style: GoogleFonts.poppins(
                                    color: isDark
                                        ? AppColors.textWhite
                                        : AppColors.textDark,
                                    fontSize: 14,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setDialogState(() => selectedCategory = val!),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(Lang.get('cancel'),
                  style:
                      GoogleFonts.poppins(color: AppColors.textGrey)),
            ),
            GestureDetector(
              onTap: () async {
                if (nameController.text.isEmpty ||
                    priceController.text.isEmpty) { return; }
                final productId =
                    DateTime.now().millisecondsSinceEpoch.toString();
                await _firestoreService.addProduct(
                  ProductModel(
                    productId: productId,
                    shopId: shopId,
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    price: double.tryParse(priceController.text) ?? 0,
                    category: selectedCategory,
                    stock: int.tryParse(stockController.text) ?? 0,
                    isAvailable: true,
                    createdAt: DateTime.now(),
                  ),
                );
                if (!context.mounted) { return; }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      Lang.isSwahili
                          ? 'Bidhaa imeongezwa!'
                          : 'Product added successfully!',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
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
