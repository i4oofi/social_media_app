import 'package:social_media_app/features/auth/models/user_data.dart';

class ChatModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String participantOne;
  final String participantTwo;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final DateTime? lastMessageTime;
  final UserData? otherUser; // Populated dynamically in frontend layer

  ChatModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.participantOne,
    required this.participantTwo,
    this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageTime,
    this.otherUser,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, {UserData? otherUser}) {
    return ChatModel(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(map['updated_at'] as String).toLocal(),
      participantOne: map['participant_one'] as String,
      participantTwo: map['participant_two'] as String,
      lastMessage: map['last_message'] as String?,
      lastMessageSenderId: map['last_message_sender_id'] as String?,
      lastMessageTime: map['last_message_time'] != null
          ? DateTime.parse(map['last_message_time'] as String).toLocal()
          : null,
      otherUser: otherUser,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'participant_one': participantOne,
      'participant_two': participantTwo,
      'last_message': lastMessage,
      'last_message_sender_id': lastMessageSenderId,
      'last_message_time': lastMessageTime?.toUtc().toIso8601String(),
    };
  }

  ChatModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? participantOne,
    String? participantTwo,
    String? lastMessage,
    String? lastMessageSenderId,
    DateTime? lastMessageTime,
    UserData? otherUser,
  }) {
    return ChatModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      participantOne: participantOne ?? this.participantOne,
      participantTwo: participantTwo ?? this.participantTwo,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      otherUser: otherUser ?? this.otherUser,
    );
  }
}
