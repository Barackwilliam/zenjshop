import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../config/lang.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../chat/chat_screen.dart';

class AdminChatsScreen extends StatefulWidget {
  const AdminChatsScreen({super.key});

  @override
  State<AdminChatsScreen> createState() => _AdminChatsScreenState();
}

class _AdminChatsScreenState extends State<AdminChatsScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  // ✅ Pata users waliowahi kuzungumza na admin TU (si wote)
  Stream<List<_ChatUserData>> _getRealChatUsers() {
    return _firestoreService.getAdminChatUsers().asyncMap((chatDocs) async {
      final List<_ChatUserData> result = [];
      for (final chat in chatDocs) {
        final participants = List<String>.from(chat['participants'] ?? []);
        final userId = participants.firstWhere(
          (id) => id != 'admin',
          orElse: () => '',
        );
        if (userId.isEmpty) continue;

        final user = await _firestoreService.getUserData(userId);
        if (user == null) continue;

        result.add(_ChatUserData(
          user: user,
          lastMessage: chat['lastMessage'] as String? ?? '',
          lastMessageAt: (chat['lastMessageAt'] != null)
              ? (chat['lastMessageAt'] as dynamic).toDate()
              : null,
          unreadCount: (chat['unread_admin'] as int?) ?? 0,
        ));
      }
      return result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textWhite, size: 16),
          ),
        ),
        title: Text(
          Lang.isSwahili ? 'Mazungumzo Yote' : 'All Conversations',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textWhite,
          ),
        ),
      ),
      body: StreamBuilder<List<_ChatUserData>>(
        stream: _getRealChatUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          final chats = snapshot.data ?? [];
          if (chats.isEmpty) {
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
                    child: const Icon(Icons.chat_bubble_outline_rounded,
                        color: AppColors.primary, size: 46),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Lang.isSwahili
                        ? 'Hakuna mazungumzo bado'
                        : 'No conversations yet',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textWhite),
                  ),
                  Text(
                    Lang.isSwahili
                        ? 'Watumiaji watakapokutumia ujumbe\nutaonekana hapa'
                        : 'When users message you\nthey will appear here',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textGrey, height: 1.5),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              return _buildUserChatTile(chats[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserChatTile(_ChatUserData chatData) {
    final user = chatData.user;

    Color roleColor;
    IconData roleIcon;
    String roleLabel;
    if (user.role == 'shop_owner') {
      roleColor = AppColors.secondary;
      roleIcon = Icons.store_rounded;
      roleLabel = Lang.isSwahili ? 'Mwenye Duka' : 'Shop Owner';
    } else if (user.role == 'delivery') {
      roleColor = AppColors.success;
      roleIcon = Icons.delivery_dining_rounded;
      roleLabel = Lang.isSwahili ? 'Msafirishaji' : 'Delivery';
    } else {
      roleColor = AppColors.primary;
      roleIcon = Icons.person_rounded;
      roleLabel = Lang.isSwahili ? 'Mnunuzi' : 'Customer';
    }

    final hasUnread = chatData.unreadCount > 0;

    return GestureDetector(
      onTap: () {
        // ✅ Reset admin unread count when opening chat
        final adminId = _authService.currentUser?.uid ?? 'admin';
        _firestoreService.resetUnreadCount(adminId, user.uid);
        _firestoreService.markMessagesRead(user.uid, adminId);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              receiverId: user.uid,
              receiverName: user.name,
              receiverRole: roleLabel,
              senderOverride: 'admin', // ✅ Admin daima anatumia 'admin' kama senderId
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasUnread
              ? AppColors.bgCard.withValues(alpha: 0.95)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasUnread ? AppColors.primary.withValues(alpha: 0.4) : const Color(0xFF2A3158),
            width: hasUnread ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ✅ Avatar with unread dot
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [roleColor, roleColor.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: roleColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // ✅ Unread dot indicator
                if (hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          chatData.unreadCount > 9 ? '9+' : '${chatData.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Info + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w700,
                          color: AppColors.textWhite,
                        ),
                      ),
                      // ✅ Wakati wa ujumbe wa mwisho
                      if (chatData.lastMessageAt != null)
                        Text(
                          _formatTime(chatData.lastMessageAt!),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: hasUnread ? AppColors.primary : AppColors.textGrey,
                            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(roleIcon, color: roleColor, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        roleLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: roleColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  // ✅ Last message preview
                  if (chatData.lastMessage.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      chatData.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: hasUnread ? AppColors.textWhite : AppColors.textGrey,
                        fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}';
  }
}

class _ChatUserData {
  final UserModel user;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  _ChatUserData({
    required this.user,
    required this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
  });
}
