import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../config/lang.dart';
import '../../services/cart_service.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../models/order_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  String _selectedPayment = 'mpesa';
  bool _isLoading = false;

  final Map<String, Map<String, String>> _paymentMethods = {
    'mpesa': {'name': 'M-Pesa', 'number': '0767-XXXXXX', 'icon': '📱'},
    'tigo': {'name': 'Tigo Pesa', 'number': '0716-XXXXXX', 'icon': '📲'},
    'airtel': {'name': 'Airtel Money', 'number': '0785-XXXXXX', 'icon': '💳'},
  };

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _placeOrder() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Lang.isSwahili ? 'Weka anwani yako' : 'Enter your address',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final cartService = Provider.of<CartService>(context, listen: false);
    final customerId = _authService.currentUser?.uid ?? '';
    final address = _addressController.text.trim();

    // Gawanya cart items kwa kila duka — kila duka linaweza kuwa order yake
    final Map<String, List<CartItem>> itemsByShop = {};
    for (final item in cartService.items) {
      final sid = item.product.shopId;
      itemsByShop.putIfAbsent(sid, () => []).add(item);
    }

    bool allSuccess = true;
    for (final entry in itemsByShop.entries) {
      final shopId = entry.key;
      final shopItems = entry.value;
      final shopTotal =
          shopItems.fold<double>(0, (sum, i) => sum + i.total);
      final orderId =
          '${DateTime.now().millisecondsSinceEpoch}_$shopId'.substring(0, 20);

      final order = OrderModel(
        orderId: orderId,
        customerId: customerId,
        shopId: shopId,
        items: shopItems
            .map((i) => {
                  'productId': i.product.productId,
                  'name': i.product.name,
                  'price': i.product.price,
                  'quantity': i.quantity,
                  'total': i.total,
                })
            .toList(),
        totalAmount: shopTotal,
        paymentMethod: _selectedPayment,
        paymentStatus: 'pending',
        orderStatus: 'pending',
        deliveryAddress: address,
        createdAt: DateTime.now(),
      );

      final success = await _firestoreService.createOrder(order);
      if (!success) allSuccess = false;
    }

    setState(() => _isLoading = false);

    if (allSuccess) {
      cartService.clearCart();
      if (!mounted) return;
      _showSuccessDialog();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Lang.isSwahili ? 'Imeshindwa. Jaribu tena' : 'Failed. Try again',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showSuccessDialog() {
    final payment = _paymentMethods[_selectedPayment]!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(
          context,
          listen: false,
        );
        final isDark = themeProvider.isDark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.bgCard : AppColors.bgCardLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                Lang.isSwahili ? 'Agizo Limefanikiwa! 🎉' : 'Order Placed! 🎉',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textWhite : AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                Lang.isSwahili ? 'Tafadhali lipa kwa:' : 'Please pay via:',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isDark ? AppColors.textGrey : AppColors.textDarkGrey,
                ),
              ),
              const SizedBox(height: 16),
              // Payment Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.secondary.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${payment['icon']!} ${payment['name']!}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? AppColors.textWhite : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Lang.isSwahili ? 'Lipa Namba:' : 'Pay Number:',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color:
                            isDark
                                ? AppColors.textGrey
                                : AppColors.textDarkGrey,
                      ),
                    ),
                    Text(
                      payment['number']!,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Lang.isSwahili
                          ? 'Jina: ZenjShop Tanzania'
                          : 'Name: ZenjShop Tanzania',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color:
                            isDark
                                ? AppColors.textGrey
                                : AppColors.textDarkGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                Lang.isSwahili
                    ? 'Baada ya kulipa, agizo lako litashughulikiwa na admin.'
                    : 'After payment, your order will be processed by admin.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? AppColors.textGrey : AppColors.textDarkGrey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/customer');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    Lang.isSwahili ? 'Rudi Nyumbani' : 'Back to Home',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final cartService = Provider.of<CartService>(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:
                            isDark ? AppColors.bgCard : AppColors.bgCardLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isDark
                                  ? const Color(0xFF2A3158)
                                  : const Color(0xFFDDE0FF),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color:
                            isDark ? AppColors.textWhite : AppColors.textDark,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    Lang.isSwahili ? 'Malipo' : 'Checkout',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textWhite : AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Items
                    Text(
                      Lang.isSwahili ? 'Bidhaa Zako' : 'Your Items',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? AppColors.textWhite : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...cartService.items.map(
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              isDark ? AppColors.bgCard : AppColors.bgCardLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                isDark
                                    ? const Color(0xFF2A3158)
                                    : const Color(0xFFDDE0FF),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isDark
                                              ? AppColors.textWhite
                                              : AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    'TSh ${item.product.price.toStringAsFixed(0)} x ${item.quantity}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color:
                                          isDark
                                              ? AppColors.textGrey
                                              : AppColors.textDarkGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'TSh ${item.total.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Delivery Address
                    Text(
                      Lang.isSwahili
                          ? 'Anwani ya Delivery'
                          : 'Delivery Address',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? AppColors.textWhite : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressController,
                      style: GoogleFonts.poppins(
                        color:
                            isDark ? AppColors.textWhite : AppColors.textDark,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            Lang.isSwahili
                                ? 'Mfano: Kariakoo, Dar es Salaam'
                                : 'E.g: Kariakoo, Dar es Salaam',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Payment Method
                    Text(
                      Lang.isSwahili ? 'Njia ya Malipo' : 'Payment Method',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? AppColors.textWhite : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ..._paymentMethods.entries.map((entry) {
                      final isSelected = _selectedPayment == entry.key;
                      return GestureDetector(
                        onTap:
                            () => setState(() => _selectedPayment = entry.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : isDark
                                    ? AppColors.bgCard
                                    : AppColors.bgCardLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppColors.primary
                                      : isDark
                                      ? const Color(0xFF2A3158)
                                      : const Color(0xFFDDE0FF),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                entry.value['icon']!,
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.value['name']!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isDark
                                                ? AppColors.textWhite
                                                : AppColors.textDark,
                                      ),
                                    ),
                                    Text(
                                      entry.value['number']!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color:
                                            isDark
                                                ? AppColors.textGrey
                                                : AppColors.textDarkGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? AppColors.primary
                                            : isDark
                                            ? AppColors.textGrey
                                            : AppColors.textDarkGrey,
                                    width: 2,
                                  ),
                                  color:
                                      isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                ),
                                child:
                                    isSelected
                                        ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 14,
                                        )
                                        : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // Order Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            isDark ? AppColors.bgCard : AppColors.bgCardLight,
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
                          _buildSummaryRow(
                            Lang.isSwahili
                                ? 'Bidhaa (${cartService.itemCount})'
                                : 'Items (${cartService.itemCount})',
                            'TSh ${cartService.totalAmount.toStringAsFixed(0)}',
                            isDark,
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            Lang.isSwahili ? 'Delivery' : 'Delivery Fee',
                            Lang.isSwahili ? 'Bure' : 'Free',
                            isDark,
                            valueColor: AppColors.success,
                          ),
                          const Divider(height: 20),
                          _buildSummaryRow(
                            Lang.isSwahili ? 'Jumla' : 'Total',
                            'TSh ${cartService.totalAmount.toStringAsFixed(0)}',
                            isDark,
                            isBold: true,
                            valueColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Place Order Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: _isLoading ? null : _placeOrder,
                child: Container(
                  width: double.infinity,
                  height: 58,
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
                  child: Center(
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                            : Text(
                              Lang.isSwahili ? 'Tuma Agizo' : 'Place Order',
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    bool isDark, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isDark ? AppColors.textGrey : AppColors.textDarkGrey,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color:
                valueColor ??
                (isDark ? AppColors.textWhite : AppColors.textDark),
          ),
        ),
      ],
    );
  }
}
