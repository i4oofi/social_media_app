import 'package:social_media_app/core/models/chat_model.dart';

abstract class InboxState {}

class InboxInitial extends InboxState {}

class InboxLoading extends InboxState {}

class InboxSuccess extends InboxState {
  final List<ChatModel> chats;
  final Map<String, int> unreadCounts;
  final String currentUserId;

  InboxSuccess({
    required this.chats,
    required this.unreadCounts,
    required this.currentUserId,
  });

  int get totalUnreadCount => unreadCounts.values.fold(0, (sum, count) => sum + count);
}

class InboxFailure extends InboxState {
  final String errorMessage;
  InboxFailure(this.errorMessage);
}
