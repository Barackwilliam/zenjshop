import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../services/cart_service.dart';
import '../../models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.info,
      AppColors.success,
    ];
    final color = colors[widget.product.name.length % colors.length];

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image Header
                  Stack(
                    children: [
                      Container(
                        height: 320,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.2),
                              color.withOpacity(0.05),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child:
                            widget.product.productImage != null &&
                                    widget.product.productImage!.isNotEmpty
                                ? CachedNetworkImage(
                                  imageUrl: widget.product.productImage!,
                                  fit: BoxFit.contain,
                                  placeholder:
                                      (c, u) => Center(
                                        child: Icon(
                                          Icons.shopping_bag_outlined,
                                          color: color.withOpacity(0.4),
                                          size: 100,
                                        ),
                                      ),
                                  errorWidget:
                                      (c, u, e) => Center(
                                        child: Icon(
                                          Icons.shopping_bag_outlined,
                                          color: color.withOpacity(0.4),
                                          size: 100,
                                        ),
                                      ),
                                )
                                : Center(
                                  child: Icon(
                                    Icons.shopping_bag_outlined,
                                    color: color.withOpacity(0.4),
                                    size: 100,
                                  ),
                                ),
                      ),
                      // Back button
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color:
                                        isDark
                                            ? AppColors.bgCard.withOpacity(0.9)
                                            : Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    color:
                                        isDark
                                            ? AppColors.textWhite
                                            : AppColors.textDark,
                                    size: 18,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap:
                                    () => setState(
                                      () => _isFavorite = !_isFavorite,
                                    ),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color:
                                        isDark
                                            ? AppColors.bgCard.withOpacity(0.9)
                                            : Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Icon(
                                    _isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: AppColors.error,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Product Info
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            widget.product.category,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Product Name
                        Text(
                          widget.product.name,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color:
                                isDark
                                    ? AppColors.textWhite
                                    : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Rating + Stock
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (i) => Icon(
                                i < 4
                                    ? Icons.star_rounded
                                    : Icons.star_half_rounded,
                                color: AppColors.gold,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '4.8',
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
                              ' (${widget.product.stock} in stock)',
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
                        const SizedBox(height: 20),

                        // Price
                        Row(
                          children: [
                            Text(
                              'TSh ',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              widget.product.price.toStringAsFixed(0),
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Description
                        Text(
                          'Description',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark
                                    ? AppColors.textWhite
                                    : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.description.isNotEmpty
                              ? widget.product.description
                              : 'This is a quality product available at ZenjShop. Order now and get fast delivery right to your door!',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color:
                                isDark
                                    ? AppColors.textGrey
                                    : AppColors.textDarkGrey,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Quantity Selector
                        Text(
                          'Quantity',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark
                                    ? AppColors.textWhite
                                    : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_quantity > 1) setState(() => _quantity--);
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? AppColors.bgCard
                                          : AppColors.bgCardLight,
                                  borderRadius: BorderRadius.circular(13),
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
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                '$_quantity',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color:
                                      isDark
                                          ? AppColors.textWhite
                                          : AppColors.textDark,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _quantity++),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(13),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Total: TSh ${(widget.product.price * _quantity).toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Features
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? AppColors.bgCard
                                    : AppColors.bgCardLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  isDark
                                      ? const Color(0xFF2A3158)
                                      : const Color(0xFFDDE0FF),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildFeatureTile(
                                Icons.local_shipping_rounded,
                                'Fast Delivery',
                                'Delivered to your door',
                                isDark,
                              ),
                              const Divider(height: 20),
                              _buildFeatureTile(
                                Icons.verified_rounded,
                                'Verified Product',
                                'Quality guaranteed',
                                isDark,
                              ),
                              const Divider(height: 20),
                              _buildFeatureTile(
                                Icons.replay_rounded,
                                'Easy Returns',
                                '7 days return policy',
                                isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Add to Cart Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
              border: Border(
                top: BorderSide(
                  color:
                      isDark
                          ? const Color(0xFF2A3158)
                          : const Color(0xFFDDE0FF),
                  width: 1,
                ),
              ),
            ),
            child: GestureDetector(
              onTap: () {
                final cartService = Provider.of<CartService>(
                  context,
                  listen: false,
                );
                for (int i = 0; i < _quantity; i++) {
                  cartService.addToCart(widget.product);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${widget.product.name} added to cart!',
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
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_shopping_cart_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Add to Cart',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(
    IconData icon,
    String title,
    String sub,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textWhite : AppColors.textDark,
              ),
            ),
            Text(
              sub,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isDark ? AppColors.textGrey : AppColors.textDarkGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
