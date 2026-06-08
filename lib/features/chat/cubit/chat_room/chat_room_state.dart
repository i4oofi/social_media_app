import 'package:social_media_app/core/models/chat_model.dart';
import 'package:social_media_app/core/models/message_model.dart';

abstract class ChatRoomState {}

class ChatRoomInitial extends ChatRoomState {}

class ChatRoomLoading extends ChatRoomState {}

class ChatRoomSuccess extends ChatRoomState {
  final ChatModel chat;
  final List<MessageModel> messages;
  final String currentUserId;
  final bool isSending;

  ChatRoomSuccess({
    required this.chat,
    required this.messages,
    required this.currentUserId,
    this.isSending = false,
  });

  ChatRoomSuccess copyWith({
    ChatModel? chat,
    List<MessageModel>? messages,
    String? currentUserId,
    bool? isSending,
  }) {
    return ChatRoomSuccess(
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
      currentUserId: currentUserId ?? this.currentUserId,
      isSending: isSending ?? this.isSending,
    );
  }
}

class ChatRoomFailure extends ChatRoomState {
  final String errorMessage;
  ChatRoomFailure(this.errorMessage);
}
