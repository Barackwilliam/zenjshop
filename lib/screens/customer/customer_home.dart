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

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome>
    with TickerProviderStateMixin {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  late AnimationController _bannerController;
  late Animation<double> _bannerAnim;
  int _selectedIndex = 0;
  int _selectedCategory = 0;
  String _searchQuery = '';
  String _userName = 'Loading...';
  String _userEmail = '';
  String _userPhone = '';
  int _currentBanner = 0;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps_rounded, 'color': AppColors.primary},
    {
      'name': 'Electronics',
      'icon': Icons.devices_rounded,
      'color': Color(0xFF00B4D8),
    },
    {
      'name': 'Clothing',
      'icon': Icons.checkroom_rounded,
      'color': Color(0xFFFF6B9D),
    },
    {
      'name': 'Food',
      'icon': Icons.fastfood_rounded,
      'color': Color(0xFFFF9F1C),
    },
    {
      'name': 'Beauty',
      'icon': Icons.face_retouching_natural_rounded,
      'color': Color(0xFFE040FB),
    },
    {'name': 'Home', 'icon': Icons.home_rounded, 'color': Color(0xFF00BFA5)},
    {
      'name': 'Sports',
      'icon': Icons.sports_soccer_rounded,
      'color': Color(0xFF69F0AE),
    },
  ];

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Fast Delivery\nTo Your Door',
      'sub': 'Order now & get it today',
      'tag': '🚀 Express Delivery',
      'gradient': [Color(0xFF6C63FF), Color(0xFFFF6B35)],
      'image': 'https://cdn-icons-png.flaticon.com/512/4290/4290854.png',
    },
    {
      'title': 'Best Shops\nIn Tanzania',
      'sub': 'Verified & trusted sellers',
      'tag': '✅ Verified Shops',
      'gradient': [Color(0xFF00B4D8), Color(0xFF0077B6)],
      'image': 'https://cdn-icons-png.flaticon.com/512/3081/3081559.png',
    },
    {
      'title': 'Pay Easily\nWith Mobile Money',
      'sub': 'M-Pesa, Tigo, Airtel',
      'tag': '💳 Secure Payment',
      'gradient': [Color(0xFF00D68F), Color(0xFF00A86B)],
      'image': 'https://cdn-icons-png.flaticon.com/512/2489/2489756.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _bannerAnim = Tween<double>(begin: 0, end: 1).animate(_bannerController);
    _loadUserData();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      setState(() {
        _currentBanner = (_currentBanner + 1) % _banners.length;
      });
      return true;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _firestoreService.getUserData(user.uid);
      if (mounted && userData != null) {
        setState(() {
          _userName = userData.name;
          _userEmail = userData.email;
          _userPhone = userData.phone;
        });
      }
    }
  }

  void _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final cartService = Provider.of<CartService>(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child:
            _selectedIndex == 0
                ? _buildHomeTab(isDark)
                : _selectedIndex == 1
                ? _buildShopsTab(isDark)
                : _selectedIndex == 2
                ? _buildCartTab(isDark, cartService)
                : _buildProfileTab(isDark, themeProvider),
      ),
      bottomNavigationBar: _buildBottomNav(isDark, cartService),
    );
  }

  // ==================== HOME TAB ====================
  Widget _buildHomeTab(bool isDark) {
    return SingleChildScrollView(
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
    return Container(
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
                      color: AppColors.primary.withOpacity(0.4),
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
                  Text(
                    'ZenjShop',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      foreground:
                          Paint()
                            ..shader = const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ).createShader(const Rect.fromLTWH(0, 0, 150, 30)),
                    ),
                  ),
                  Text(
                    'Tanzania\'s #1 Marketplace',
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
              // ── MABADILIKO #1: Notification bell → NotificationsScreen + StreamBuilder ──
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                child: StreamBuilder<int>(
                  stream: FirestoreService().getUnreadNotificationsCount(
                    _authService.currentUser?.uid ?? '',
                  ),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return Container(
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
                          width: 1,
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
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              _buildIconButton(
                icon: Icons.person_rounded,
                isDark: isDark,
                isGradient: true,
                onTap: () => setState(() => _selectedIndex = 3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isDark,
    bool badge = false,
    bool isGradient = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: isGradient ? AppColors.primaryGradient : null,
          color:
              isGradient
                  ? null
                  : isDark
                  ? AppColors.bgCard
                  : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(13),
          border:
              isGradient
                  ? null
                  : Border.all(
                    color:
                        isDark
                            ? const Color(0xFF2A3158)
                            : const Color(0xFFDDE0FF),
                    width: 1,
                  ),
          boxShadow:
              isGradient
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              color:
                  isGradient
                      ? Colors.white
                      : isDark
                      ? AppColors.textLight
                      : AppColors.textDark,
              size: 22,
            ),
            if (badge)
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
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          style: GoogleFonts.poppins(
            color: isDark ? AppColors.textWhite : AppColors.textDark,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Search products, shops...',
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
                    : Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
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
                    color: (banner['gradient'] as List<Color>).first
                        .withOpacity(0.4),
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
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    bottom: -40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
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
                      placeholder: (context, url) => const SizedBox(),
                      errorWidget:
                          (context, url, error) => const Icon(
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
                            color: Colors.white.withOpacity(0.2),
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
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            'Shop Now →',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: (banner['gradient'] as List<Color>).first,
                              fontWeight: FontWeight.w700,
                            ),
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
            children: List.generate(_banners.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentBanner == index ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  gradient:
                      _currentBanner == index
                          ? AppColors.primaryGradient
                          : null,
                  color:
                      _currentBanner == index
                          ? null
                          : isDark
                          ? const Color(0xFF2A3158)
                          : const Color(0xFFDDE0FF),
                  borderRadius: BorderRadius.circular(50),
                ),
              );
            }),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textWhite : AppColors.textDark,
                ),
              ),
              Text(
                'See All',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedCategory == index;
              final cat = _categories[index];
              final color = cat['color'] as Color;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = index),
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
                                      color: color.withOpacity(0.4),
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
                'Featured Shops',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textWhite : AppColors.textDark,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 1),
                child: Text(
                  'See All',
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
            stream: _firestoreService.getActiveShops(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No shops yet',
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
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return _buildShopCard(snapshot.data![index], isDark);
                },
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
      onTap: () => setState(() => _selectedIndex = 1),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
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
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
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
                            (c, u, e) => Center(
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
                        color: Colors.white.withOpacity(0.9),
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
                        color: Colors.white.withOpacity(0.9),
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
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      shop.category,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: AppColors.primary,
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
                selectedCat ?? 'All Products',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textWhite : AppColors.textDark,
                ),
              ),
              Text(
                'Sort by ▾',
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
          stream: _firestoreService.getAllProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
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
                        'No products yet',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? AppColors.textWhite : AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Check back later for amazing deals!',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color:
                              isDark
                                  ? AppColors.textGrey
                                  : AppColors.textDarkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            var products = snapshot.data!;
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
                    'No products found',
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
              itemBuilder: (context, index) {
                return _buildProductCard(products[index], isDark);
              },
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
      // ── MABADILIKO #2: Product card inafungua ProductDetailScreen ──
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
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
                    colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                            (c, u) => Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: color.withOpacity(0.4),
                                size: 50,
                              ),
                            ),
                        errorWidget:
                            (c, u, e) => Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: color.withOpacity(0.5),
                                size: 50,
                              ),
                            ),
                      )
                    else
                      Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: color.withOpacity(0.5),
                          size: 50,
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? AppColors.bgCard.withOpacity(0.9)
                                  : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          color: AppColors.error,
                          size: 18,
                        ),
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
                          color: color.withOpacity(0.9),
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
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.gold,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '4.8',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color:
                              isDark
                                  ? AppColors.textGrey
                                  : AppColors.textDarkGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' (${product.stock})',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color:
                              isDark
                                  ? AppColors.textGrey
                                  : AppColors.textDarkGrey,
                        ),
                      ),
                    ],
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
                          final cartService = Provider.of<CartService>(
                            context,
                            listen: false,
                          );
                          cartService.addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.name} added to cart!',
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
                                color: color.withOpacity(0.4),
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
                  'All Shops',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : AppColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_list_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Filter',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ShopModel>>(
            stream: _firestoreService.getActiveShops(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                        'No shops available',
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
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return _buildShopListTile(snapshot.data![index], isDark);
                },
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

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
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
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  if (shop.shopImage != null && shop.shopImage!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: shop.shopImage!,
                      width: double.infinity,
                      height: 90,
                      fit: BoxFit.cover,
                      errorWidget:
                          (c, u, e) => Center(
                            child: Icon(
                              Icons.store_rounded,
                              color: Colors.white.withOpacity(0.8),
                              size: 40,
                            ),
                          ),
                    )
                  else
                    Center(
                      child: Icon(
                        Icons.store_rounded,
                        color: Colors.white.withOpacity(0.8),
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
                        color: Colors.white.withOpacity(0.9),
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
                              isDark ? AppColors.textWhite : AppColors.textDark,
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
                              color: gradient.first.withOpacity(0.1),
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
                color: AppColors.primary.withOpacity(0.1),
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
              'Your Cart is Empty',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textWhite : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add products to start shopping!',
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
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  'Start Shopping',
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
                    'My Cart',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textWhite : AppColors.textDark,
                    ),
                  ),
                  Text(
                    '${cartService.itemCount} items',
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
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                      width: 1,
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
                        'Clear All',
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
            itemBuilder: (context, index) {
              final item = cartService.items[index];
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
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                        ),
                        child:
                            item.product.productImage != null &&
                                    item.product.productImage!.isNotEmpty
                                ? CachedNetworkImage(
                                  imageUrl: item.product.productImage!,
                                  fit: BoxFit.cover,
                                  errorWidget:
                                      (c, u, e) => Icon(
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
                                width: 1,
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
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckoutScreen(),
                    ),
                  );
                },
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
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Checkout',
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
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
                        color: Colors.white.withOpacity(0.2),
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
                  _userName,
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
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            color: AppColors.gold,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Verified Member',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
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
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    StreamBuilder<List<OrderModel>>(
                      stream: _firestoreService.getCustomerOrders(
                          _authService.currentUser?.uid ?? ''),
                      builder: (context, snap) {
                        final count = snap.data?.length ?? 0;
                        return _buildProfileStat(
                          'Orders',
                          '$count',
                          Icons.receipt_long_rounded,
                          isDark,
                        );
                      },
                    ),
                    const SizedBox(width: 14),
                    _buildProfileStat(
                      'Wishlist',
                      '0',
                      Icons.favorite_rounded,
                      isDark,
                    ),
                    const SizedBox(width: 14),
                    _buildProfileStat(
                      'Reviews',
                      '0',
                      Icons.star_rounded,
                      isDark,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'Preferences',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 14),

                _buildSettingsTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark Mode',
                  subtitle: isDark ? 'Currently on' : 'Currently off',
                  isDark: isDark,
                  trailing: Switch(
                    value: isDark,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    activeColor: AppColors.primary,
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  subtitle: Lang.isSwahili ? 'Swahili' : 'English',
                  isDark: isDark,
                  trailing: GestureDetector(
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
                // ── MABADILIKO #3: My Orders tile inafungua MyOrdersScreen ──
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyOrdersScreen(),
                      ),
                    );
                  },
                  child: _buildSettingsTile(
                    icon: Icons.receipt_long_rounded,
                    title: 'My Orders',
                    subtitle: 'Track your orders',
                    isDark: isDark,
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.location_on_rounded,
                  title: 'Delivery Address',
                  subtitle: 'Manage addresses',
                  isDark: isDark,
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  subtitle: '24/7 customer support',
                  isDark: isDark,
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About ZenjShop',
                  subtitle: 'Version 1.0.0',
                  isDark: isDark,
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: _logout,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                        width: 1,
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
                          'Sign Out',
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

  Widget _buildProfileStat(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
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

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
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
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
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
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.store_outlined),
            activeIcon: const Icon(Icons.store_rounded),
            label: 'Shops',
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
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outlined),
            activeIcon: const Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
