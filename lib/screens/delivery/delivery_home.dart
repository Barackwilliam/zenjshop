import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../config/lang.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/network_service.dart';
import '../../models/delivery_model.dart';

class DeliveryHome extends StatefulWidget {
  const DeliveryHome({super.key});

  @override
  State<DeliveryHome> createState() => _DeliveryHomeState();
}

class _DeliveryHomeState extends State<DeliveryHome> with ConnectivityMixin {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  int _selectedIndex = 0;
  String? _currentUserId;
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';

  @override
  void initState() {
    super.initState(); // calls checkConnectivity via mixin
    _currentUserId = _authService.currentUser?.uid;
    _loadUserData();
  }

  void _loadUserData() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      final data = await _firestoreService.getUserData(uid);
      if (mounted && data != null) {
        setState(() {
          _userName = data.name;
          _userEmail = data.email;
          _userPhone = data.phone;
        });
      }
    }
  }

  void _logout() async {
    await _authService.logout();
    if (!mounted) {
      return;
    }
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            buildOfflineBanner(),
            Expanded(
              child:
                  _selectedIndex == 0
                      ? _buildDashboard(isDark)
                      : _selectedIndex == 1
                      ? _buildActiveDeliveries(isDark)
                      : _buildProfileTab(isDark, themeProvider),
            ),
          ],
        ),
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
                      color:
                          isDark ? AppColors.textGrey : AppColors.textDarkGrey,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback:
                        (bounds) => const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ).createShader(bounds),
                    child: Text(
                      Lang.isSwahili ? 'Msafirishaji' : 'Delivery',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
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

          const SizedBox(height: 24),

          // Stats
          StreamBuilder(
            stream: _firestoreService.getDeliveryPersonOrders(
              _currentUserId ?? '',
            ),
            builder: (context, snapshot) {
              final deliveries = snapshot.data ?? [];
              final active =
                  deliveries
                      .where(
                        (d) =>
                            d.status == 'assigned' ||
                            d.status == 'picked_up' ||
                            d.status == 'on_the_way',
                      )
                      .length;
              final completed =
                  deliveries.where((d) => d.status == 'delivered').length;

              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.4,
                children: [
                  _buildStatCard(
                    title: Lang.isSwahili ? 'Zinazoendelea' : 'Active',
                    value: '$active',
                    icon: Icons.delivery_dining_rounded,
                    color: AppColors.primary,
                    isDark: isDark,
                  ),
                  _buildStatCard(
                    title: Lang.isSwahili ? 'Zilizokamilika' : 'Completed',
                    value: '$completed',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                    isDark: isDark,
                  ),
                  _buildStatCard(
                    title: Lang.isSwahili ? 'Zote' : 'Total',
                    value: '${deliveries.length}',
                    icon: Icons.list_alt_rounded,
                    color: AppColors.secondary,
                    isDark: isDark,
                  ),
                  _buildStatCard(
                    title: Lang.isSwahili ? 'Leo' : 'Today',
                    value:
                        '${deliveries.where((d) {
                          final today = DateTime.now();
                          return d.assignedAt.day == today.day && d.assignedAt.month == today.month && d.assignedAt.year == today.year;
                        }).length}',
                    icon: Icons.today_rounded,
                    color: AppColors.warning,
                    isDark: isDark,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Available Orders — Orders zilizoidhinishwa zinazosubiri msafirishaji
          Text(
            Lang.isSwahili ? 'Maagizo Yanayopatikana' : 'Available Orders',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),

          StreamBuilder(
            stream: _firestoreService.getAllOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final available =
                  (snapshot.data ?? [])
                      .where(
                        (o) =>
                            o.orderStatus == 'confirmed' &&
                            o.deliveryPersonId == null,
                      )
                      .toList();

              if (available.isEmpty) {
                return _buildEmptyState(
                  Lang.isSwahili
                      ? 'Hakuna maagizo yanayopatikana sasa'
                      : 'No available orders right now',
                  isDark,
                );
              }

              return Column(
                children:
                    available
                        .map((order) => _buildAvailableOrderCard(order, isDark))
                        .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== ACTIVE DELIVERIES ====================
  Widget _buildActiveDeliveries(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            Lang.isSwahili ? 'Deliveries Zangu' : 'My Deliveries',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : AppColors.textDark,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: _firestoreService.getDeliveryPersonOrders(
              _currentUserId ?? '',
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState(
                  Lang.isSwahili ? 'Huna deliveries bado' : 'No deliveries yet',
                  isDark,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return _buildDeliveryCard(snapshot.data![index], isDark);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== PROFILE TAB ====================
  Widget _profileStatCard(
    bool isDark,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textWhite : AppColors.textDark,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isDark ? AppColors.textGrey : AppColors.textDarkGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(bool isDark, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.success, Color(0xFF00A86B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.delivery_dining_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _userName.isNotEmpty
                      ? _userName
                      : (Lang.isSwahili ? 'Msafirishaji' : 'Delivery Person'),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userEmail.isNotEmpty
                      ? _userEmail
                      : (_authService.currentUser?.email ?? ''),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                if (_userPhone.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.phone_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _userPhone,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder(
            stream: _firestoreService.getDeliveryPersonOrders(
              _currentUserId ?? '',
            ),
            builder: (context, snap) {
              final deliveries = snap.data ?? [];
              final completed =
                  deliveries.where((d) => d.status == 'delivered').length;
              final active =
                  deliveries.where((d) => d.status != 'delivered').length;
              return Row(
                children: [
                  _profileStatCard(
                    isDark,
                    Lang.isSwahili ? 'Zote' : 'Total',
                    '${deliveries.length}',
                    Icons.list_alt_rounded,
                    AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  _profileStatCard(
                    isDark,
                    Lang.isSwahili ? 'Zinazoendelea' : 'Active',
                    '$active',
                    Icons.delivery_dining_rounded,
                    AppColors.warning,
                  ),
                  const SizedBox(width: 12),
                  _profileStatCard(
                    isDark,
                    Lang.isSwahili ? 'Zilizokamilika' : 'Done',
                    '$completed',
                    Icons.check_circle_rounded,
                    AppColors.success,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
                  const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
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

  Widget _buildAvailableOrderCard(dynamic order, bool isDark) {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  Lang.isSwahili ? 'INAPATIKANA' : 'AVAILABLE',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
                    color: isDark ? AppColors.textGrey : AppColors.textDarkGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                color: AppColors.primary,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'TSh ${order.totalAmount.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Accept Button
          GestureDetector(
            onTap: () async {
              final deliveryId =
                  DateTime.now().millisecondsSinceEpoch.toString();
              // Andika delivery record mpya
              await _firestoreService.createDelivery(
                DeliveryModel(
                  deliveryId: deliveryId,
                  orderId: order.orderId,
                  deliveryPersonId: _currentUserId ?? '',
                  shopId: order.shopId,
                  customerId: order.customerId,
                  status: 'picked_up',
                  shopLocation: 'Tanzania',
                  customerLocation: order.deliveryAddress,
                  assignedAt: DateTime.now(),
                ),
              );
              // Weka deliveryPersonId kwenye order na badilisha status
              await _firestoreService.assignDeliveryPerson(
                order.orderId,
                _currentUserId ?? '',
              );
              await _firestoreService.updateOrderStatus(
                order.orderId,
                'picked_up',
              );
              if (!mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    Lang.isSwahili
                        ? 'Umekubali delivery!'
                        : 'Delivery accepted!',
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
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.success, Color(0xFF00A86B)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  Lang.isSwahili ? 'Kubali Delivery' : 'Accept Delivery',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(dynamic delivery, bool isDark) {
    Color statusColor = AppColors.warning;
    String statusText = delivery.status;
    if (delivery.status == 'delivered') statusColor = AppColors.success;
    if (delivery.status == 'on_the_way') statusColor = AppColors.primary;
    if (delivery.status == 'picked_up') statusColor = AppColors.info;

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
                '#${delivery.deliveryId.substring(0, 8).toUpperCase()}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textWhite : AppColors.textDark,
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
                  statusText.toUpperCase(),
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
          // Delivery Route
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 30,
                    color:
                        isDark
                            ? const Color(0xFF2A3158)
                            : const Color(0xFFDDE0FF),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delivery.shopLocation.isNotEmpty
                          ? delivery.shopLocation
                          : 'Duka',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color:
                            isDark
                                ? AppColors.textLight
                                : AppColors.textDarkLight,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      delivery.customerLocation.isNotEmpty
                          ? delivery.customerLocation
                          : 'Mteja',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color:
                            isDark
                                ? AppColors.textLight
                                : AppColors.textDarkLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Update Status Buttons
          if (delivery.status != 'delivered')
            Row(
              children: [
                if (delivery.status == 'assigned')
                  Expanded(
                    child: _buildStatusButton(
                      label: Lang.isSwahili ? 'Nimeichukua' : 'Picked Up',
                      color: AppColors.info,
                      onTap:
                          () => _firestoreService.updateDeliveryStatus(
                            delivery.deliveryId,
                            'picked_up',
                          ),
                    ),
                  ),
                if (delivery.status == 'picked_up') ...[
                  Expanded(
                    child: _buildStatusButton(
                      label: Lang.isSwahili ? 'Njiani' : 'On The Way',
                      color: AppColors.primary,
                      onTap:
                          () => _firestoreService.updateDeliveryStatus(
                            delivery.deliveryId,
                            'on_the_way',
                          ),
                    ),
                  ),
                ],
                if (delivery.status == 'on_the_way') ...[
                  Expanded(
                    child: _buildStatusButton(
                      label: Lang.isSwahili ? 'Imefika' : 'Delivered',
                      color: AppColors.success,
                      onTap:
                          () => _firestoreService.updateDeliveryStatus(
                            delivery.deliveryId,
                            'delivered',
                          ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusButton({
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

  Widget _buildEmptyState(String message, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delivery_dining_outlined,
            size: 60,
            color:
                isDark
                    ? AppColors.textGrey.withValues(alpha: 0.3)
                    : AppColors.textDarkGrey.withValues(alpha: 0.3),
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
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard_rounded),
            label: Lang.isSwahili ? 'Dashibodi' : 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.delivery_dining_outlined),
            activeIcon: const Icon(Icons.delivery_dining_rounded),
            label: Lang.isSwahili ? 'Deliveries' : 'Deliveries',
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
}
