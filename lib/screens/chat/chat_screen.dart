import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/chat_model.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverRole;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverRole,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final _scrollController = ScrollController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _authService.currentUser?.uid;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final message = ChatMessage(
      messageId: messageId,
      senderId: _currentUserId ?? '',
      receiverId: widget.receiverId,
      message: _messageController.text.trim(),
      createdAt: DateTime.now(),
      isRead: false,
    );
    _messageController.clear();
    await _firestoreService.sendMessage(message);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

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
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.receiverName[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : AppColors.textDark,
                  ),
                ),
                Text(
                  widget.receiverRole,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _firestoreService.getMessages(
                _currentUserId ?? '',
                widget.receiverId,
              ),
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
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark
                                    ? AppColors.textWhite
                                    : AppColors.textDark,
                          ),
                        ),
                        Text(
                          'Say hello to ${widget.receiverName}!',
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
                  );
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == _currentUserId;
                    return _buildMessageBubble(msg, isMe, isDark);
                  },
                );
              },
            ),
          ),
          // Input
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? AppColors.bgSurface
                              : AppColors.bgSurfaceLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color:
                            isDark
                                ? const Color(0xFF2A3158)
                                : const Color(0xFFDDE0FF),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: GoogleFonts.poppins(
                        color:
                            isDark ? AppColors.textWhite : AppColors.textDark,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: GoogleFonts.poppins(
                          color:
                              isDark
                                  ? AppColors.textGrey
                                  : AppColors.textDarkGrey,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.receiverName[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isMe ? AppColors.primaryGradient : null,
              color:
                  isMe
                      ? null
                      : isDark
                      ? AppColors.bgCard
                      : AppColors.bgCardLight,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              border:
                  isMe
                      ? null
                      : Border.all(
                        color:
                            isDark
                                ? const Color(0xFF2A3158)
                                : const Color(0xFFDDE0FF),
                        width: 1,
                      ),
              boxShadow: [
                BoxShadow(
                  color:
                      isMe
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  msg.message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color:
                        isMe
                            ? Colors.white
                            : isDark
                            ? AppColors.textWhite
                            : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color:
                        isMe
                            ? Colors.white.withValues(alpha: 0.7)
                            : isDark
                            ? AppColors.textGrey
                            : AppColors.textDarkGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
