import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../config/lang.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/sound_service.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _soundService = SoundService();
  List<NotificationModel> _prevNotifs = [];
  bool _firstLoad = true;

  void _onNewNotifications(List<NotificationModel> notifs) {
    if (_firstLoad) {
      _prevNotifs = notifs;
      _firstLoad = false;
      return;
    }
    // Lia sauti kama kuna notification mpya
    if (notifs.length > _prevNotifs.length) {
      _soundService.playNotificationSound();
    }
    _prevNotifs = notifs;
  }

  void _confirmDeleteAll(String userId) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.bgCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          Lang.isSwahili ? 'Futa Historia Yote?' : 'Delete All History?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : AppColors.textDark),
        ),
        content: Text(
          Lang.isSwahili
              ? 'Arifa zote zitafutwa kabisa. Huwezi kuzirejesha.'
              : 'All notifications will be permanently deleted. This cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 13,
              color: isDark ? AppColors.textGrey : AppColors.textDarkGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Lang.isSwahili ? 'Hapana' : 'Cancel',
                style: GoogleFonts.poppins(color: AppColors.textGrey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _firestoreService.deleteAllNotifications(userId);
            },
            child: Text(Lang.isSwahili ? 'Futa Zote' : 'Delete All',
                style: GoogleFonts.poppins(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final userId = _authService.currentUser?.uid ?? '';

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
            child: Icon(Icons.arrow_back_ios_new,
                color: isDark ? AppColors.textWhite : AppColors.textDark, size: 16),
          ),
        ),
        title: Text(
          Lang.isSwahili ? 'Arifa' : 'Notifications',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : AppColors.textDark),
        ),
        actions: [
          // Mark all read
          GestureDetector(
            onTap: () async {
              await _firestoreService.markAllNotificationsRead(userId);
              await _firestoreService.markAllNotificationsRead('admin');
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(Lang.isSwahili ? 'Soma Zote' : 'Read All',
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ),
          // ✅ Delete all button
          GestureDetector(
            onTap: () => _confirmDeleteAll(userId),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_sweep_rounded, color: AppColors.error, size: 14),
                  const SizedBox(width: 4),
                  Text(Lang.isSwahili ? 'Futa Zote' : 'Clear All',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _firestoreService.getMergedNotifications(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          // ✅ Detect new notifications and play sound
          if (snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _onNewNotifications(snapshot.data!);
            });
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 46),
                  ),
                  const SizedBox(height: 16),
                  Text(Lang.isSwahili ? 'Hakuna arifa bado' : 'No notifications yet',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textWhite : AppColors.textDark)),
                  const SizedBox(height: 8),
                  Text(
                    Lang.isSwahili ? 'Arifa zako zitaonekana hapa' : 'Your notifications will appear here',
                    style: GoogleFonts.poppins(fontSize: 13,
                        color: isDark ? AppColors.textGrey : AppColors.textDarkGrey),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!;
          final unreadCount = notifications.where((n) => !n.isRead).length;

          return Column(
            children: [
              if (unreadCount > 0)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.secondary.withValues(alpha: 0.1),
                    ]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    Container(width: 8, height: 8,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Text(
                      Lang.isSwahili
                          ? 'Una arifa $unreadCount mpya'
                          : 'You have $unreadCount unread notification${unreadCount == 1 ? '' : 's'}',
                      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ]),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    // ✅ Swipe to delete
                    return Dismissible(
                      key: Key(notif.notificationId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.delete_rounded, color: AppColors.error, size: 26),
                      ),
                      onDismissed: (_) async {
                        await _firestoreService.deleteNotification(notif.notificationId);
                      },
                      child: GestureDetector(
                        onTap: () => _firestoreService.markNotificationRead(notif.notificationId),
                        // ✅ Long press = delete single
                        onLongPress: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await _firestoreService.deleteNotification(notif.notificationId);
                          if (!mounted) return;
                          messenger.showSnackBar(SnackBar(
                              content: Text(Lang.isSwahili ? 'Arifa imefutwa' : 'Notification deleted',
                                  style: GoogleFonts.poppins(fontSize: 13)),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 2),
                            ));
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: notif.isRead
                                ? (isDark ? AppColors.bgCard : AppColors.bgCardLight)
                                : (isDark
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : AppColors.primary.withValues(alpha: 0.05)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: notif.isRead
                                  ? (isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF))
                                  : AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 46, height: 46,
                                decoration: BoxDecoration(
                                  color: _getNotifColor(notif.type).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(_getNotifIcon(notif.type),
                                    color: _getNotifColor(notif.type), size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(notif.title,
                                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700,
                                                  color: isDark ? AppColors.textWhite : AppColors.textDark)),
                                        ),
                                        if (!notif.isRead)
                                          Container(width: 8, height: 8,
                                              decoration: const BoxDecoration(
                                                  color: AppColors.primary, shape: BoxShape.circle)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(notif.body,
                                        style: GoogleFonts.poppins(fontSize: 12, height: 1.4,
                                            color: isDark ? AppColors.textGrey : AppColors.textDarkGrey)),
                                    const SizedBox(height: 6),
                                    Row(children: [
                                      const Icon(Icons.access_time_rounded, size: 12, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text(_formatTime(notif.createdAt),
                                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
                                      const Spacer(),
                                      // ✅ Swipe hint
                                      Icon(Icons.swipe_left_rounded, size: 12,
                                          color: isDark ? AppColors.textGrey.withValues(alpha: 0.5) : AppColors.textDarkGrey.withValues(alpha: 0.5)),
                                    ]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getNotifColor(String type) {
    switch (type) {
      case 'new_order': return AppColors.primary;
      case 'order_confirmed': return AppColors.success;
      case 'order_cancelled': return AppColors.error;
      case 'delivery_update': return AppColors.info;
      case 'chat_message': return AppColors.secondary;
      default: return AppColors.warning;
    }
  }

  IconData _getNotifIcon(String type) {
    switch (type) {
      case 'new_order': return Icons.receipt_long_rounded;
      case 'order_confirmed': return Icons.check_circle_rounded;
      case 'order_cancelled': return Icons.cancel_rounded;
      case 'delivery_update': return Icons.delivery_dining_rounded;
      case 'chat_message': return Icons.chat_bubble_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return Lang.isSwahili ? 'Sasa hivi' : 'Just now';
    if (diff.inMinutes < 60) return Lang.isSwahili ? 'Dakika ${diff.inMinutes} zilizopita' : '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return Lang.isSwahili ? 'Saa ${diff.inHours} zilizopita' : '${diff.inHours}h ago';
    if (diff.inDays < 7) return Lang.isSwahili ? 'Siku ${diff.inDays} zilizopita' : '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
