import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../config/lang.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/cart_service.dart';
import '../../models/shop_model.dart';
import '../../models/product_model.dart';
import '../../models/order_model.dart';
import 'checkout_screen.dart';
import 'product_detail_screen.dart';
import 'my_orders_screen.dart';
import '../notifications/notifications_screen.dart';
import '../shared/shop_detail_screen.dart';
import '../shared/help_support_screen.dart';
import '../shared/about_screen.dart';
import '../shared/delivery_address_screen.dart';
import '../chat/chat_screen.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});
  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  late AnimationController _bannerController;
  late Stream<List<ProductModel>> _productsStream;
  late Stream<List<ShopModel>> _shopsStream;
  int _selectedIndex = 0;
  int _selectedCategory = 0;
  String _searchQuery = '';
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  int _currentBanner = 0;
  bool _isOffline = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps_rounded, 'color': AppColors.primary},
    {
      'name': 'Electronics',
      'icon': Icons.devices_rounded,
      'color': const Color(0xFF00B4D8),
    },
    {
      'name': 'Clothing',
      'icon': Icons.checkroom_rounded,
      'color': const Color(0xFFFF6B9D),
    },
    {
      'name': 'Food',
      'icon': Icons.fastfood_rounded,
      'color': const Color(0xFFFF9F1C),
    },
    {
      'name': 'Beauty',
      'icon': Icons.face_retouching_natural_rounded,
      'color': const Color(0xFFE040FB),
    },
    {
      'name': 'Home',
      'icon': Icons.home_rounded,
      'color': const Color(0xFF00BFA5),
    },
    {
      'name': 'Sports',
      'icon': Icons.sports_soccer_rounded,
      'color': const Color(0xFF69F0AE),
    },
  ];

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Fast Delivery\nTo Your Door',
      'sub': 'Order now & get it today',
      'tag': '🚀 Express Delivery',
      'gradient': [const Color(0xFF6C63FF), const Color(0xFFFF6B35)],
      'image': 'https://cdn-icons-png.flaticon.com/512/4290/4290854.png',
    },
    {
      'title': 'Best Shops\nIn Tanzania',
      'sub': 'Verified & trusted sellers',
      'tag': '✅ Verified Shops',
      'gradient': [const Color(0xFF00B4D8), const Color(0xFF0077B6)],
      'image': 'https://cdn-icons-png.flaticon.com/512/3081/3081559.png',
    },
    {
      'title': 'Pay Easily\nWith Any Network',
      'sub': 'One number — all networks',
      'tag': '💳 Secure Payment',
      'gradient': [const Color(0xFF00D68F), const Color(0xFF00A86B)],
      'image': 'https://cdn-icons-png.flaticon.com/512/2489/2489756.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Store streams as stable fields — prevents re-subscription on every setState (banner, search)
    _productsStream = _firestoreService.getAllProducts();
    _shopsStream = _firestoreService.getActiveShops();
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _loadUserData();
    _checkConnectivity();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) {
        return false;
      }
      setState(() => _currentBanner = (_currentBanner + 1) % _banners.length);
      return true;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      if (mounted) setState(() => _isOffline = result.isEmpty);
    } catch (_) {
      if (mounted) setState(() => _isOffline = true);
    }
  }

  void _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final data = await _firestoreService.getUserData(user.uid);
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
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final cartService = Provider.of<CartService>(context);
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Offline banner
            if (_isOffline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: AppColors.error.withValues(alpha: 0.9),
                child: Row(
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        Lang.isSwahili
                            ? 'Hakuna mtandao. Tafadhali angalia muunganisho wako wa intaneti.'
                            : 'No internet connection. Please check your network.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _checkConnectivity,
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildHomeTab(isDark),
                  _buildShopsTab(isDark),
                  _buildCartTab(isDark, cartService),
                  _buildProfileTab(isDark, Provider.of<ThemeProvider>(context)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isDark, cartService),
      floatingActionButton: (_selectedIndex == 0 || _selectedIndex == 1)
          ? GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    receiverId: 'admin',
                    receiverName: 'ZenjShop Admin',
                    receiverRole: Lang.isSwahili ? 'Msimamizi wa App' : 'App Administrator',
                  ),
                ),
              ),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.chat_rounded, color: Colors.white, size: 26),
                    // Unread badge
                    StreamBuilder<int>(
                      stream: _firestoreService.getUnreadNotificationsCount(
                          _authService.currentUser?.uid ?? ''),
                      builder: (context, snap) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  // ==================== HOME ====================
  Widget _buildHomeTab(bool isDark) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          _buildSearchBar(isDark),
          _buildBannerSlider(isDark),
          _buildCategories(isDark),
          _buildFeaturedShops(isDark),
          _buildAllProducts(isDark),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_bag_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback:
                        (b) => const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ).createShader(b),
                    child: Text(
                      'ZenjShop',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    "Tanzania's #1 Marketplace",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color:
                          isDark ? AppColors.textGrey : AppColors.textDarkGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              StreamBuilder<int>(
                stream: _firestoreService.getUnreadNotificationsCount(
                  _authService.currentUser?.uid ?? '',
                ),
                builder: (context, snap) {
                  final count = snap.data ?? 0;
                  return GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        ),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:
                            isDark ? AppColors.bgCard : AppColors.bgCardLight,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color:
                              isDark
                                  ? const Color(0xFF2A3158)
                                  : const Color(0xFFDDE0FF),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            color:
                                isDark
                                    ? AppColors.textLight
                                    : AppColors.textDark,
                            size: 22,
                          ),
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
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 3),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: GoogleFonts.poppins(
            color: isDark ? AppColors.textWhite : AppColors.textDark,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText:
                Lang.isSwahili
                    ? 'Tafuta bidhaa, maduka...'
                    : 'Search products, shops...',
            hintStyle: GoogleFonts.poppins(
              color: isDark ? AppColors.textGrey : AppColors.textDarkGrey,
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color:
                            isDark
                                ? AppColors.textGrey
                                : AppColors.textDarkGrey,
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                    : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSlider(bool isDark) {
    final banner = _banners[_currentBanner];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Container(
              key: ValueKey(_currentBanner),
              height: 170,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: (banner['gradient'] as List).cast<Color>(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (banner['gradient'] as List<Color>).first.withValues(
                      alpha: 0.4,
                    ),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: CachedNetworkImage(
                      imageUrl: banner['image'] as String,
                      width: 110,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const SizedBox(),
                      errorWidget:
                          (_, __, ___) => const Icon(
                            Icons.shopping_bag_rounded,
                            color: Colors.white30,
                            size: 80,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            banner['tag'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          banner['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          banner['sub'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _banners.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentBanner == i ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  gradient:
                      _currentBanner == i ? AppColors.primaryGradient : null,
                  color:
                      _currentBanner == i
                          ? null
                          : isDark
                          ? const Color(0xFF2A3158)
                          : const Color(0xFFDDE0FF),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Text(
            Lang.isSwahili ? 'Makundi' : 'Categories',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : AppColors.textDark,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _categories.length,
            itemBuilder: (context, i) {
              final isSelected = _selectedCategory == i;
              final cat = _categories[i];
              final color = cat['color'] as Color;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 14),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? color
                                  : isDark
                                  ? AppColors.bgCard
                                  : AppColors.bgCardLight,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color:
                                isSelected
                                    ? color
                                    : isDark
                                    ? const Color(0xFF2A3158)
                                    : const Color(0xFFDDE0FF),
                            width: 1.5,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                  : [],
                        ),
                        child: Icon(
                          cat['icon'] as IconData,
                          color: isSelected ? Colors.white : color,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['name'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color:
                              isSelected
                                  ? color
                                  : isDark
                                  ? AppColors.textGrey
                                  : AppColors.textDarkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedShops(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Lang.isSwahili ? 'Maduka Maarufu' : 'Featured Shops',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textWhite : AppColors.textDark,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 1),
                child: Text(
                  Lang.isSwahili ? 'Ona Zote' : 'See All',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 150,
          child: StreamBuilder<List<ShopModel>>(
            stream: _shopsStream,
            builder: (context, snap) {
              if (!snap.hasData || snap.data!.isEmpty) {
                return Center(
                  child: Text(
                    Lang.isSwahili ? 'Hakuna maduka bado' : 'No shops yet',
                    style: GoogleFonts.poppins(
                      color:
                          isDark ? AppColors.textGrey : AppColors.textDarkGrey,
                      fontSize: 13,
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: snap.data!.length,
                itemBuilder: (_, i) => _buildShopCard(snap.data![i], isDark),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShopCard(ShopModel shop, bool isDark) {
    final gradients = [
      [const Color(0xFF6C63FF), const Color(0xFF4B44CC)],
      [const Color(0xFFFF6B35), const Color(0xFFFF9A3C)],
      [const Color(0xFF00D68F), const Color(0xFF00A86B)],
      [const Color(0xFF00B4D8), const Color(0xFF0077B6)],
    ];
    final gradient = gradients[shop.name.length % gradients.length];
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ShopDetailScreen(shop: shop)),
          ),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  if (shop.shopImage != null && shop.shopImage!.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: shop.shopImage!,
                        width: double.infinity,
                        height: 80,
                        fit: BoxFit.cover,
                        errorWidget:
                            (_, __, ___) => Center(
                              child: Icon(
                                Icons.store_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                      ),
                    )
                  else
                    Center(
                      child: Icon(
                        Icons.store_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 36,
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            color: AppColors.primary,
                            size: 10,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Verified',
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.name,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark
                                    ? AppColors.textWhite
                                    : AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.secondary,
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                shop.location.isNotEmpty
                                    ? shop.location
                                    : 'Tanzania',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color:
                                      isDark
                                          ? AppColors.textGrey
                                          : AppColors.textDarkGrey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: gradient.first.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      shop.category,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: gradient.first,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllProducts(bool isDark) {
    final selectedCat =
        _selectedCategory == 0
            ? null
            : _categories[_selectedCategory]['name'] as String;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedCat ??
                    (Lang.isSwahili ? 'Bidhaa Zote' : 'All Products'),
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textWhite : AppColors.textDark,
                ),
              ),
              Text(
                Lang.isSwahili ? 'Panga ▾' : 'Sort ▾',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        StreamBuilder<List<ProductModel>>(
          stream: _productsStream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            if (!snap.hasData || snap.data!.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        Lang.isSwahili
                            ? 'Hakuna bidhaa bado'
                            : 'No products yet',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? AppColors.textWhite : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            var products = snap.data!;
            if (selectedCat != null) {
              products =
                  products.where((p) => p.category == selectedCat).toList();
            }
            if (_searchQuery.isNotEmpty) {
              products =
                  products
                      .where(
                        (p) => p.name.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                      )
                      .toList();
            }
            if (products.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(30),
                child: Center(
                  child: Text(
                    Lang.isSwahili
                        ? 'Hakuna bidhaa zilizopatikana'
                        : 'No products found',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color:
                          isDark ? AppColors.textGrey : AppColors.textDarkGrey,
                    ),
                  ),
                ),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemCount: products.length,
              itemBuilder: (_, i) => _buildProductCard(products[i], isDark),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product, bool isDark) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.info,
      AppColors.success,
    ];
    final color = colors[product.name.length % colors.length];
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    if (product.productImage != null &&
                        product.productImage!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: product.productImage!,
                        width: double.infinity,
                        height: 130,
                        fit: BoxFit.cover,
                        placeholder:
                            (_, __) => Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: color.withValues(alpha: 0.4),
                                size: 50,
                              ),
                            ),
                        errorWidget:
                            (_, __, ___) => Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: color.withValues(alpha: 0.4),
                                size: 50,
                              ),
                            ),
                      )
                    else
                      Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: color.withValues(alpha: 0.5),
                          size: 50,
                        ),
                      ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          product.category,
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textWhite : AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock: ${product.stock}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color:
                          isDark ? AppColors.textGrey : AppColors.textDarkGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TSh',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color:
                                  isDark
                                      ? AppColors.textGrey
                                      : AppColors.textDarkGrey,
                            ),
                          ),
                          Text(
                            product.price.toStringAsFixed(0),
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Provider.of<CartService>(
                            context,
                            listen: false,
                          ).addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.name} ${Lang.isSwahili ? 'imeongezwa!' : 'added!'}',
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SHOPS TAB ====================
  Widget _buildShopsTab(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  Lang.isSwahili ? 'Maduka Yote' : 'All Shops',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ShopModel>>(
            stream: _shopsStream,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (!snap.hasData || snap.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.store_outlined,
                        size: 60,
                        color: AppColors.textGrey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        Lang.isSwahili ? 'Hakuna maduka' : 'No shops available',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color:
                              isDark
                                  ? AppColors.textGrey
                                  : AppColors.textDarkGrey,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: snap.data!.length,
                itemBuilder:
                    (_, i) => _buildShopListTile(snap.data![i], isDark),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShopListTile(ShopModel shop, bool isDark) {
    final gradients = [
      [const Color(0xFF6C63FF), const Color(0xFF4B44CC)],
      [const Color(0xFFFF6B35), const Color(0xFFFF9A3C)],
      [const Color(0xFF00D68F), const Color(0xFF00A86B)],
      [const Color(0xFF00B4D8), const Color(0xFF0077B6)],
    ];
    final gradient = gradients[shop.name.length % gradients.length];
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ShopDetailScreen(shop: shop)),
          ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    if (shop.shopImage != null && shop.shopImage!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: shop.shopImage!,
                        width: double.infinity,
                        height: 90,
                        fit: BoxFit.cover,
                        errorWidget:
                            (_, __, ___) => Center(
                              child: Icon(
                                Icons.store_rounded,
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 40,
                              ),
                            ),
                      )
                    else
                      Center(
                        child: Icon(
                          Icons.store_rounded,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 40,
                        ),
                      ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.gold,
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '4.8',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.store_rounded,
                      color: Colors.white,
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
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark
                                    ? AppColors.textWhite
                                    : AppColors.textDark,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: gradient.first.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                shop.category,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: gradient.first,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.secondary,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                shop.location.isNotEmpty
                                    ? shop.location
                                    : 'Tanzania',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color:
                                      isDark
                                          ? AppColors.textGrey
                                          : AppColors.textDarkGrey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CART TAB ====================
  Widget _buildCartTab(bool isDark, CartService cartService) {
    if (cartService.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              Lang.isSwahili ? 'Gari Lako Liko Tupu' : 'Your Cart is Empty',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textWhite : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Lang.isSwahili
                  ? 'Ongeza bidhaa kuanza kununua!'
                  : 'Add products to start shopping!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? AppColors.textGrey : AppColors.textDarkGrey,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => setState(() => _selectedIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  Lang.isSwahili ? 'Anza Kununua' : 'Start Shopping',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Lang.isSwahili ? 'Gari Langu' : 'My Cart',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textWhite : AppColors.textDark,
                    ),
                  ),
                  Text(
                    '${cartService.itemCount} ${Lang.isSwahili ? 'bidhaa' : 'items'}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color:
                          isDark ? AppColors.textGrey : AppColors.textDarkGrey,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => cartService.clearCart(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        Lang.isSwahili ? 'Futa Zote' : 'Clear All',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.error,
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
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: cartService.items.length,
            itemBuilder: (_, i) {
              final item = cartService.items[i];
              final colors = [
                AppColors.primary,
                AppColors.secondary,
                AppColors.info,
                AppColors.success,
              ];
              final color = colors[item.product.name.length % colors.length];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        isDark
                            ? const Color(0xFF2A3158)
                            : const Color(0xFFDDE0FF),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                        ),
                        child:
                            item.product.productImage != null &&
                                    item.product.productImage!.isNotEmpty
                                ? CachedNetworkImage(
                                  imageUrl: item.product.productImage!,
                                  fit: BoxFit.cover,
                                  errorWidget:
                                      (_, __, ___) => Icon(
                                        Icons.shopping_bag_outlined,
                                        color: color,
                                        size: 32,
                                      ),
                                )
                                : Icon(
                                  Icons.shopping_bag_outlined,
                                  color: color,
                                  size: 32,
                                ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color:
                                  isDark
                                      ? AppColors.textWhite
                                      : AppColors.textDark,
                            ),
                          ),
                          Text(
                            item.product.category,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color:
                                  isDark
                                      ? AppColors.textGrey
                                      : AppColors.textDarkGrey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'TSh ${item.total.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap:
                              () => cartService.increaseQuantity(
                                item.product.productId,
                              ),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            '${item.quantity}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color:
                                  isDark
                                      ? AppColors.textWhite
                                      : AppColors.textDark,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap:
                              () => cartService.decreaseQuantity(
                                item.product.productId,
                              ),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? AppColors.bgSurface
                                      : AppColors.bgSurfaceLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    isDark
                                        ? const Color(0xFF2A3158)
                                        : const Color(0xFFDDE0FF),
                              ),
                            ),
                            child: Icon(
                              Icons.remove_rounded,
                              color:
                                  isDark
                                      ? AppColors.textGrey
                                      : AppColors.textDarkGrey,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
            border: Border(
              top: BorderSide(
                color:
                    isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Lang.isSwahili ? 'Jumla' : 'Total Amount',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color:
                            isDark
                                ? AppColors.textGrey
                                : AppColors.textDarkGrey,
                      ),
                    ),
                    Text(
                      'TSh ${cartService.totalAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                    ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        Lang.isSwahili ? 'Malipo' : 'Checkout',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== PROFILE TAB ====================
  Widget _buildProfileTab(bool isDark, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Profile header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Stack(
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
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _userName.isNotEmpty ? _userName : 'User',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _userEmail,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                if (_userPhone.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
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

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Stats
                Row(
                  children: [
                    StreamBuilder<List<OrderModel>>(
                      stream: _firestoreService.getCustomerOrders(
                        _authService.currentUser?.uid ?? '',
                      ),
                      builder:
                          (_, snap) => _profileStat(
                            isDark,
                            Lang.isSwahili ? 'Maagizo' : 'Orders',
                            '${snap.data?.length ?? 0}',
                            Icons.receipt_long_rounded,
                          ),
                    ),
                    const SizedBox(width: 14),
                    _profileStat(
                      isDark,
                      Lang.isSwahili ? 'Wishlist' : 'Wishlist',
                      '0',
                      Icons.favorite_rounded,
                    ),
                    const SizedBox(width: 14),
                    _profileStat(
                      isDark,
                      Lang.isSwahili ? 'Maoni' : 'Reviews',
                      '0',
                      Icons.star_rounded,
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Text(
                  Lang.isSwahili ? 'Mipangilio' : 'Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : AppColors.textDark,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 14),

                _settingsTile(
                  isDark,
                  Icons.dark_mode_rounded,
                  Lang.isSwahili ? 'Hali ya Giza' : 'Dark Mode',
                  isDark
                      ? (Lang.isSwahili ? 'Imewashwa' : 'On')
                      : (Lang.isSwahili ? 'Imezimwa' : 'Off'),
                  Switch(
                    value: isDark,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    activeColor: AppColors.primary,
                  ),
                ),
                _settingsTile(
                  isDark,
                  Icons.language_rounded,
                  Lang.isSwahili ? 'Lugha' : 'Language',
                  Lang.isSwahili ? 'Kiswahili' : 'English',
                  GestureDetector(
                    onTap: () => setState(() => Lang.toggle()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        Lang.isSwahili ? '🇹🇿 SW' : '🇬🇧 EN',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyOrdersScreen(),
                        ),
                      ),
                  child: _settingsTile(
                    isDark,
                    Icons.receipt_long_rounded,
                    Lang.isSwahili ? 'Maagizo Yangu' : 'My Orders',
                    Lang.isSwahili
                        ? 'Fuatilia maagizo yako'
                        : 'Track your orders',
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeliveryAddressScreen(),
                        ),
                      ),
                  child: _settingsTile(
                    isDark,
                    Icons.location_on_rounded,
                    Lang.isSwahili ? 'Anwani ya Delivery' : 'Delivery Address',
                    Lang.isSwahili ? 'Simamia anwani zako' : 'Manage addresses',
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                ),
                // ✅ Chat na Admin
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        receiverId: 'admin',
                        receiverName: 'ZenjShop Admin',
                        receiverRole: Lang.isSwahili ? 'Msimamizi wa App' : 'App Administrator',
                      ),
                    ),
                  ),
                  child: _settingsTile(
                    isDark,
                    Icons.chat_rounded,
                    Lang.isSwahili ? 'Zungumza na Admin' : 'Chat with Admin',
                    Lang.isSwahili ? 'Maswali, malalamiko, msaada' : 'Questions, complaints, support',
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 16),
                  ),
                ),
                GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen(),
                        ),
                      ),
                  child: _settingsTile(
                    isDark,
                    Icons.help_outline_rounded,
                    Lang.isSwahili ? 'Msaada & Mawasiliano' : 'Help & Support',
                    Lang.isSwahili ? 'Msaada 24/7' : '24/7 customer support',
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      ),
                  child: _settingsTile(
                    isDark,
                    Icons.info_outline_rounded,
                    Lang.isSwahili ? 'Kuhusu ZenjShop' : 'About ZenjShop',
                    'Version 1.0.0',
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.primary,
                      size: 16,
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
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          color: AppColors.error,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          Lang.isSwahili ? 'Toka' : 'Sign Out',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileStat(bool isDark, String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
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
                fontSize: 11,
                color: isDark ? AppColors.textGrey : AppColors.textDarkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile(
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
    Widget trailing,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textWhite : AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isDark ? AppColors.textGrey : AppColors.textDarkGrey,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  // ==================== BOTTOM NAV ====================
  Widget _buildBottomNav(bool isDark, CartService cartService) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor:
            isDark ? AppColors.textGrey : AppColors.textDarkGrey,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: Lang.isSwahili ? 'Nyumbani' : 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.store_outlined),
            activeIcon: const Icon(Icons.store_rounded),
            label: Lang.isSwahili ? 'Maduka' : 'Shops',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (cartService.itemCount > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${cartService.itemCount}',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: const Icon(Icons.shopping_cart_rounded),
            label: Lang.isSwahili ? 'Gari' : 'Cart',
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
