class ChatMessage {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      messageId: map['messageId'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      message: map['message'],
      createdAt: DateTime.parse(map['createdAt']),
      isRead: map['isRead'] ?? false,
    );
  }
}
