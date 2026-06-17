import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/models/chat_model.dart';
import 'package:social_media_app/features/chat/services/chat_services.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'chat_room_state.dart';
import 'package:social_media_app/core/di/service_locator.dart';

class ChatRoomCubit extends Cubit<ChatRoomState> {
  ChatRoomCubit() : super(ChatRoomInitial());

  StreamSubscription? _messagesSubscription;
  final ChatServices _chatServices = sl<ChatServices>();
  final CoreAuthServices _coreAuthServices = sl<CoreAuthServices>();

  void initChatRoom({ChatModel? chat, String? otherUserId}) async {
    emit(ChatRoomLoading());
    try {
      final currentUser = await _coreAuthServices.getCurrentUserData();
      if (currentUser == null) {
        emit(ChatRoomFailure("User not authenticated"));
        return;
      }
      final currentUserId = currentUser.id;

      ChatModel activeChat;
      if (chat != null) {
        activeChat = chat;
      } else if (otherUserId != null) {
        activeChat = await _chatServices.getOrCreateChat(currentUserId, otherUserId);
      } else {
        emit(ChatRoomFailure("Invalid chat initialization arguments"));
        return;
      }

      // Mark existing messages as read
      await _chatServices.markMessagesAsRead(activeChat.id, currentUserId);

      // Subscribe to messages stream
      _messagesSubscription?.cancel();
      _messagesSubscription = _chatServices.subscribeToMessages(activeChat.id).listen((messages) {
        // Mark new incoming messages as read
        _chatServices.markMessagesAsRead(activeChat.id, currentUserId);

        final currentState = state;
        if (currentState is ChatRoomSuccess) {
          emit(currentState.copyWith(messages: messages));
        } else {
          emit(ChatRoomSuccess(
            chat: activeChat,
            messages: messages,
            currentUserId: currentUserId,
          ));
        }
      }, onError: (error) {
        emit(ChatRoomFailure(error.toString()));
      });

    } catch (e) {
      emit(ChatRoomFailure(e.toString()));
    }
  }

  Future<void> sendMessage(String content) async {
    final currentState = state;
    if (currentState is ChatRoomSuccess && content.trim().isNotEmpty) {
      try {
        final chat = currentState.chat;
        final senderId = currentState.currentUserId;
        final recipientId = chat.participantOne == senderId ? chat.participantTwo : chat.participantOne;

        // Note: No need to optimistically insert into message list because the realtime stream will automatically pick it up and update the UI.
        await _chatServices.sendMessage(
          chatId: chat.id,
          senderId: senderId,
          recipientId: recipientId,
          content: content.trim(),
        );
      } catch (e) {
        emit(ChatRoomFailure(e.toString()));
      }
    }
  }

  Future<void> sendImage(String filePath, String fileName) async {
    final currentState = state;
    if (currentState is ChatRoomSuccess) {
      try {
        final chat = currentState.chat;
        final senderId = currentState.currentUserId;
        final recipientId = chat.participantOne == senderId ? chat.participantTwo : chat.participantOne;

        emit(currentState.copyWith(isSending: true));
        
        // Upload file to Supabase Storage
        final imageUrl = await _chatServices.uploadChatAttachment(filePath, fileName);

        // Send message with image URL as content
        await _chatServices.sendMessage(
          chatId: chat.id,
          senderId: senderId,
          recipientId: recipientId,
          content: imageUrl,
        );
        emit(currentState.copyWith(isSending: false));
      } catch (e) {
        emit(currentState.copyWith(isSending: false));
        emit(ChatRoomFailure(e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
