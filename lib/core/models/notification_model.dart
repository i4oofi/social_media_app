class NotificationModel {
  final String id;
  final String createdAt;
  final String receiverId;
  final String senderId;
  final String type; // 'like', 'comment', 'follow'
  final String? postId;
  final bool isRead;
  
  // Dynamic fields populated from user data
  final String? senderName;
  final String? senderImageUrl;

  NotificationModel({
    required this.id,
    required this.createdAt,
    required this.receiverId,
    required this.senderId,
    required this.type,
    this.postId,
    required this.isRead,
    this.senderName,
    this.senderImageUrl,
  });

  NotificationModel copyWith({
    String? id,
    String? createdAt,
    String? receiverId,
    String? senderId,
    String? type,
    String? postId,
    bool? isRead,
    String? senderName,
    String? senderImageUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      receiverId: receiverId ?? this.receiverId,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      postId: postId ?? this.postId,
      isRead: isRead ?? this.isRead,
      senderName: senderName ?? this.senderName,
      senderImageUrl: senderImageUrl ?? this.senderImageUrl,
    );
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      createdAt: map['created_at'] ?? '',
      receiverId: map['receiver_id'] ?? '',
      senderId: map['sender_id'] ?? '',
      type: map['type'] ?? '',
      postId: map['post_id'],
      isRead: map['is_read'] ?? false,
      senderName: map['sender_name'],
      senderImageUrl: map['sender_image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'receiver_id': receiverId,
      'sender_id': senderId,
      'type': type,
      'post_id': postId,
      'is_read': isRead,
      'sender_name': senderName,
      'sender_image_url': senderImageUrl,
    };
  }
}
