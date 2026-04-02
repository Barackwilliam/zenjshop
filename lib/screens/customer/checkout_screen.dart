import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isLoading = false;

  // Payment info — single method accepts all networks + bank
  static const String _paymentNumber = '22567522';
  static const String _paymentName = 'DEVELOPMENT PP SOLUTION LTD';

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  void _loadSavedAddress() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      final userData = await _firestoreService.getUserData(uid);
      if (userData != null && mounted) {
        // Try to get saved address from user profile
        try {
          final doc = await FirestoreService().getUserData(uid);
          // address field stored in user document
          if (doc != null) {
            // We check if the user has a stored address in an extended field
            // For now we just leave blank to let user enter
          }
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _placeOrder() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(Lang.isSwahili ? 'Weka anwani yako ya delivery' : 'Enter your delivery address',
          style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }

    setState(() => _isLoading = true);

    final cartService = Provider.of<CartService>(context, listen: false);
    final customerId = _authService.currentUser?.uid ?? '';
    final address = _addressController.text.trim();

    // Group items by shop
    final Map<String, List<CartItem>> byShop = {};
    for (final item in cartService.items) {
      byShop.putIfAbsent(item.product.shopId, () => []).add(item);
    }

    bool allSuccess = true;
    for (final entry in byShop.entries) {
      final shopId = entry.key;
      final shopItems = entry.value;
      final shopTotal = shopItems.fold<double>(0, (s, i) => s + i.total);
      final orderId = '${DateTime.now().millisecondsSinceEpoch}${shopId.substring(0, 4)}';

      final order = OrderModel(
        orderId: orderId.length > 20 ? orderId.substring(0, 20) : orderId,
        customerId: customerId,
        shopId: shopId,
        items: shopItems.map((i) => {
          'productId': i.product.productId,
          'name': i.product.name,
          'price': i.product.price,
          'quantity': i.quantity,
          'total': i.total,
        }).toList(),
        totalAmount: shopTotal,
        paymentMethod: 'mobile_money',
        paymentStatus: 'pending',
        orderStatus: 'pending',
        deliveryAddress: address,
        createdAt: DateTime.now(),
      );

      final ok = await _firestoreService.createOrder(order);
      if (!ok) { allSuccess = false; }
    }

    setState(() => _isLoading = false);

    if (allSuccess) {
      cartService.clearCart();
      if (!mounted) { return; }
      _showSuccessDialog(cartService.totalAmount);
    } else {
      if (!mounted) { return; }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(Lang.isSwahili ? 'Imeshindwa. Jaribu tena.' : 'Failed. Please try again.',
          style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  void _showSuccessDialog(double totalAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Provider.of<ThemeProvider>(ctx, listen: false).isDark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.bgCard : AppColors.bgCardLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            // Success icon
            Container(width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 50)),
            const SizedBox(height: 16),
            Text(Lang.isSwahili ? 'Agizo Limetumwa! 🎉' : 'Order Placed! 🎉',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? AppColors.textWhite : AppColors.textDark),
              textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(Lang.isSwahili ? 'Tafadhali kamilisha malipo yako' : 'Please complete your payment',
              style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.textGrey : AppColors.textDarkGrey),
              textAlign: TextAlign.center),
            const SizedBox(height: 20),

            // Payment box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.12), AppColors.secondary.withValues(alpha: 0.08)]),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Column(children: [
                // Amount
                Text(Lang.isSwahili ? 'Kiasi cha Kulipa:' : 'Amount to Pay:',
                  style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.textGrey : AppColors.textDarkGrey)),
                Text('TSh ${totalAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary)),

                const SizedBox(height: 16),
                Divider(color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF)),
                const SizedBox(height: 16),

                // Payment number
                Text(Lang.isSwahili ? 'Lipa kwenye Namba Hii:' : 'Send Payment to:',
                  style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.textGrey : AppColors.textDarkGrey)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: _paymentNumber));
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(Lang.isSwahili ? 'Namba imenakiliwa!' : 'Number copied!',
                        style: GoogleFonts.poppins(fontSize: 13)),
                      backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16), duration: const Duration(seconds: 2),
                    ));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(_paymentNumber,
                        style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 3)),
                      const SizedBox(width: 10),
                      const Icon(Icons.copy_rounded, color: AppColors.primary, size: 18),
                    ]),
                  ),
                ),
                const SizedBox(height: 10),
                Text(_paymentName,
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textLight : AppColors.textDarkLight),
                  textAlign: TextAlign.center),

                const SizedBox(height: 16),
                // Networks accepted
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bgSurface : AppColors.bgSurfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(children: [
                    Text(Lang.isSwahili ? 'Inakubali mitandao yote:' : 'Accepts all networks:',
                      style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.textGrey : AppColors.textDarkGrey)),
                    const SizedBox(height: 6),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _networkBadge('M-Pesa', const Color(0xFF4CAF50)),
                      const SizedBox(width: 6),
                      _networkBadge('Tigo', const Color(0xFF2196F3)),
                      const SizedBox(width: 6),
                      _networkBadge('Airtel', const Color(0xFFFF5722)),
                      const SizedBox(width: 6),
                      _networkBadge('Benki', AppColors.primary),
                    ]),
                  ]),
                ),

                const SizedBox(height: 12),
                Text(
                  Lang.isSwahili
                      ? 'Baada ya kulipa, agizo lako litashughulikiwa na admin haraka.'
                      : 'After payment, your order will be processed by admin shortly.',
                  style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.textGrey : AppColors.textDarkGrey, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ]),
            ),

            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushReplacementNamed(ctx, '/customer');
              },
              child: Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
                child: Center(child: Text(Lang.isSwahili ? 'Rudi Nyumbani' : 'Back to Home',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white))),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _networkBadge(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(name, style: GoogleFonts.poppins(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final cartService = Provider.of<CartService>(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF))),
                  child: Icon(Icons.arrow_back_ios_new, color: isDark ? AppColors.textWhite : AppColors.textDark, size: 18)),
              ),
              const SizedBox(width: 16),
              Text(Lang.isSwahili ? 'Malipo' : 'Checkout',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : AppColors.textDark)),
            ]),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Items
                Text(Lang.isSwahili ? 'Bidhaa Zako' : 'Your Items',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : AppColors.textDark)),
                const SizedBox(height: 12),
                ...cartService.items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF)),
                  ),
                  child: Row(children: [
                    Container(width: 46, height: 46,
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 22)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.product.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textWhite : AppColors.textDark)),
                      Text('TSh ${item.product.price.toStringAsFixed(0)} × ${item.quantity}',
                        style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.textGrey : AppColors.textDarkGrey)),
                    ])),
                    Text('TSh ${item.total.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ]),
                )),

                const SizedBox(height: 20),

                // Delivery address
                Text(Lang.isSwahili ? 'Anwani ya Delivery' : 'Delivery Address',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : AppColors.textDark)),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressController,
                  style: GoogleFonts.poppins(color: isDark ? AppColors.textWhite : AppColors.textDark, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: Lang.isSwahili ? 'Mfano: Kariakoo, Dar es Salaam' : 'E.g: Kariakoo, Dar es Salaam',
                    hintStyle: GoogleFonts.poppins(color: isDark ? AppColors.textGrey : AppColors.textDarkGrey, fontSize: 13),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                ),

                const SizedBox(height: 20),

                // Payment info box
                Text(Lang.isSwahili ? 'Maelezo ya Malipo' : 'Payment Information',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : AppColors.textDark)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.secondary.withValues(alpha: 0.05)]),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 40, height: 40,
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 22)),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(Lang.isSwahili ? 'Lipa kwa mtandao wowote' : 'Pay via any network',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : AppColors.textDark)),
                        Text(Lang.isSwahili ? 'M-Pesa, Tigo, Airtel, Benki' : 'M-Pesa, Tigo, Airtel, Bank',
                          style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.textGrey : AppColors.textDarkGrey)),
                      ]),
                    ]),
                    const SizedBox(height: 16),
                    Center(child: Column(children: [
                      Text(Lang.isSwahili ? 'Namba ya Malipo:' : 'Payment Number:',
                        style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.textGrey : AppColors.textDarkGrey)),
                      const SizedBox(height: 4),
                      Text(_paymentNumber,
                        style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 4)),
                      Text(_paymentName,
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textLight : AppColors.textDarkLight),
                        textAlign: TextAlign.center),
                    ])),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(const ClipboardData(text: _paymentNumber));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(Lang.isSwahili ? 'Namba imenakiliwa!' : 'Number copied!',
                            style: GoogleFonts.poppins(fontSize: 13)),
                          backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                        ));
                      },
                      child: Container(
                        width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.copy_rounded, color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Text(Lang.isSwahili ? 'Nakili Namba' : 'Copy Number',
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      Lang.isSwahili
                          ? '⚠️ Tuma malipo BAADA ya kufanya agizo. Agizo litashughulikiwa baada ya uthibitisho wa malipo.'
                          : '⚠️ Send payment AFTER placing order. Order will be processed after payment confirmation.',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.warning, height: 1.5),
                    ),
                  ]),
                ),

                const SizedBox(height: 20),

                // Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF)),
                  ),
                  child: Column(children: [
                    _summaryRow(Lang.isSwahili ? 'Bidhaa (${cartService.itemCount})' : 'Items (${cartService.itemCount})',
                      'TSh ${cartService.totalAmount.toStringAsFixed(0)}', isDark),
                    const SizedBox(height: 8),
                    _summaryRow(Lang.isSwahili ? 'Delivery' : 'Delivery Fee',
                      Lang.isSwahili ? 'Bure 🎉' : 'Free 🎉', isDark, valueColor: AppColors.success),
                    const Divider(height: 20),
                    _summaryRow(Lang.isSwahili ? 'Jumla' : 'Total',
                      'TSh ${cartService.totalAmount.toStringAsFixed(0)}', isDark,
                      isBold: true, valueColor: AppColors.primary),
                  ]),
                ),
                const SizedBox(height: 30),
              ]),
            ),
          ),

          // Place order button
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: _isLoading ? null : _placeOrder,
              child: Container(
                width: double.infinity, height: 58,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Center(child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.shopping_cart_checkout_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(Lang.isSwahili ? 'Tuma Agizo' : 'Place Order',
                        style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                    ])),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _summaryRow(String label, String value, bool isDark, {bool isBold = false, Color? valueColor}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: isBold ? 15 : 13, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
        color: isDark ? AppColors.textGrey : AppColors.textDarkGrey)),
      Text(value, style: GoogleFonts.poppins(fontSize: isBold ? 16 : 13, fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
        color: valueColor ?? (isDark ? AppColors.textWhite : AppColors.textDark))),
    ]);
  }
}
