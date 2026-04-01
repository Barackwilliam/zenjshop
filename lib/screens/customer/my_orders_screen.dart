import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/order_model.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final userId = authService.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgSurface : AppColors.bgSurfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: isDark ? AppColors.textWhite : AppColors.textDark,
              size: 16,
            ),
          ),
        ),
        title: Text(
          'My Orders',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : AppColors.textDark,
          ),
        ),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: firestoreService.getCustomerOrders(userId),
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
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: AppColors.primary,
                      size: 46,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textWhite : AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Your order history will appear here',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color:
                          isDark ? AppColors.textGrey : AppColors.textDarkGrey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final order = snapshot.data![index];
              return _buildOrderCard(order, isDark, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, bool isDark, BuildContext context) {
    Color statusColor = AppColors.warning;
    IconData statusIcon = Icons.pending_rounded;
    String statusText = 'Pending';

    switch (order.orderStatus) {
      case 'confirmed':
        statusColor = AppColors.primary;
        statusIcon = Icons.check_circle_rounded;
        statusText = 'Confirmed';
        break;
      case 'preparing':
        statusColor = AppColors.warning;
        statusIcon = Icons.store_rounded;
        statusText = 'Preparing';
        break;
      case 'picked_up':
        statusColor = AppColors.info;
        statusIcon = Icons.delivery_dining_rounded;
        statusText = 'Picked Up';
        break;
      case 'on_the_way':
        statusColor = AppColors.primary;
        statusIcon = Icons.directions_bike_rounded;
        statusText = 'On The Way';
        break;
      case 'delivered':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        statusText = 'Delivered';
        break;
      case 'cancelled':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_rounded;
        statusText = 'Cancelled';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
          width: 1,
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.orderId.substring(0, 8).toUpperCase()}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? AppColors.textWhite : AppColors.textDark,
                        ),
                      ),
                      Text(
                        _formatDate(order.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
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
                    statusText,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...order.items
                    .take(2)
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item['name'] ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color:
                                      isDark
                                          ? AppColors.textLight
                                          : AppColors.textDarkLight,
                                ),
                              ),
                            ),
                            Text(
                              'x${item['quantity']}',
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
                    ),
                if (order.items.length > 2)
                  Text(
                    '+${order.items.length - 2} more items',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgSurface : AppColors.bgSurfaceLight,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Delivery address
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.secondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          order.deliveryAddress,
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
                ),
                // Total
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color:
                            isDark
                                ? AppColors.textGrey
                                : AppColors.textDarkGrey,
                      ),
                    ),
                    Text(
                      'TSh ${order.totalAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
