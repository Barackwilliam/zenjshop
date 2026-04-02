import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../config/lang.dart';
import '../../services/firestore_service.dart';
import '../../services/cart_service.dart';
import '../../models/shop_model.dart';
import '../../models/product_model.dart';
import '../customer/product_detail_screen.dart';

class ShopDetailScreen extends StatefulWidget {
  final ShopModel shop;
  const ShopDetailScreen({super.key, required this.shop});

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  final _firestoreService = FirestoreService();
  String _searchQuery = '';
  int _selectedCategory = 0;

  final List<String> _categories = ['All', 'Electronics', 'Clothing', 'Food', 'Beauty', 'Home', 'Sports', 'Other'];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final cartService = Provider.of<CartService>(context);

    final gradients = [
      [const Color(0xFF6C63FF), const Color(0xFF4B44CC)],
      [const Color(0xFFFF6B35), const Color(0xFFFF9A3C)],
      [const Color(0xFF00D68F), const Color(0xFF00A86B)],
      [const Color(0xFF00B4D8), const Color(0xFF0077B6)],
    ];
    final gradient = gradients[widget.shop.name.length % gradients.length];

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── AppBar with shop image ───
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: isDark ? AppColors.bgCard : AppColors.bgCardLight,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Shop image
                  if (widget.shop.shopImage != null && widget.shop.shopImage!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: widget.shop.shopImage!,
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.3),
                      colorBlendMode: BlendMode.darken,
                      errorWidget: (_, __, ___) => const SizedBox(),
                    ),
                  // Shop info overlay
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(widget.shop.category,
                                style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(children: [
                                const Icon(Icons.verified_rounded, color: Colors.white, size: 12),
                                const SizedBox(width: 4),
                                Text('ACTIVE', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                              ]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(widget.shop.name,
                          style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                        Row(children: [
                          const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(widget.shop.location.isNotEmpty ? widget.shop.location : 'Tanzania',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Shop description ───
          if (widget.shop.description.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
                  ),
                ),
                child: Text(widget.shop.description,
                  style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.textGrey : AppColors.textDarkGrey, height: 1.6)),
              ),
            ),

          // ─── Search bar ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF)),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: GoogleFonts.poppins(color: isDark ? AppColors.textWhite : AppColors.textDark, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: Lang.isSwahili ? 'Tafuta bidhaa...' : 'Search products...',
                    hintStyle: GoogleFonts.poppins(color: isDark ? AppColors.textGrey : AppColors.textDarkGrey, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
          ),

          // ─── Category chips ───
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  final isSelected = _selectedCategory == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected ? LinearGradient(colors: gradient) : null,
                        color: isSelected ? null : isDark ? AppColors.bgCard : AppColors.bgCardLight,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
                        ),
                      ),
                      child: Text(_categories[i],
                        style: GoogleFonts.poppins(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : isDark ? AppColors.textGrey : AppColors.textDarkGrey,
                        )),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ─── Products grid ───
          StreamBuilder<List<ProductModel>>(
            stream: _firestoreService.getShopProducts(widget.shop.shopId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )),
                );
              }

              var products = snapshot.data?.where((p) => p.isAvailable).toList() ?? [];
              if (_selectedCategory > 0) {
                products = products.where((p) => p.category == _categories[_selectedCategory]).toList();
              }
              if (_searchQuery.isNotEmpty) {
                products = products.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
              }

              if (products.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(children: [
                        Icon(Icons.inventory_2_outlined, size: 60, color: isDark ? AppColors.textGrey.withValues(alpha: 0.4) : AppColors.textDarkGrey.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text(Lang.isSwahili ? 'Hakuna bidhaa' : 'No products found',
                          style: GoogleFonts.poppins(fontSize: 15, color: isDark ? AppColors.textGrey : AppColors.textDarkGrey)),
                      ]),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildProductCard(products[index], isDark, cartService, gradient),
                    childCount: products.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, bool isDark, CartService cartService, List<Color> gradient) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06), blurRadius: 15, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [gradient.first.withValues(alpha: 0.15), gradient.first.withValues(alpha: 0.05)]),
                ),
                child: Stack(children: [
                  if (product.productImage != null && product.productImage!.isNotEmpty)
                    CachedNetworkImage(imageUrl: product.productImage!, width: double.infinity, height: 130, fit: BoxFit.cover,
                      placeholder: (_, __) => Center(child: Icon(Icons.shopping_bag_outlined, color: gradient.first.withValues(alpha: 0.4), size: 50)),
                      errorWidget: (_, __, ___) => Center(child: Icon(Icons.shopping_bag_outlined, color: gradient.first.withValues(alpha: 0.4), size: 50)))
                  else
                    Center(child: Icon(Icons.shopping_bag_outlined, color: gradient.first.withValues(alpha: 0.5), size: 50)),
                  Positioned(bottom: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: gradient.first.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(50)),
                      child: Text(product.category, style: GoogleFonts.poppins(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)),
                    )),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product.name,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : AppColors.textDark),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('Stock: ${product.stock}',
                  style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.textGrey : AppColors.textDarkGrey)),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('TSh', style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.textGrey : AppColors.textDarkGrey)),
                    Text(product.price.toStringAsFixed(0),
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: gradient.first)),
                  ]),
                  GestureDetector(
                    onTap: () {
                      cartService.addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${product.name} added!', style: GoogleFonts.poppins(fontSize: 13)),
                        backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16), duration: const Duration(seconds: 1),
                      ));
                    },
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: gradient.first, borderRadius: BorderRadius.circular(11),
                        boxShadow: [BoxShadow(color: gradient.first.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
