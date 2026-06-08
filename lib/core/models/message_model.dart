class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String recipientId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.createdAt,
    required this.isRead,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id.isNotEmpty ? id : (map['id'] as String? ?? ''),
      chatId: map['chat_id'] as String,
      senderId: map['sender_id'] as String,
      recipientId: map['recipient_id'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      isRead: map['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'recipient_id': recipientId,
      'content': content,
      'created_at': createdAt.toUtc().toIso8601String(),
      'is_read': isRead,
    };
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? recipientId,
    String? content,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
