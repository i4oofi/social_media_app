import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/models/chat_model.dart';
import 'package:social_media_app/core/shared/widgets/user_avatar.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/chat/cubit/chat_room/chat_room_cubit.dart';
import 'package:social_media_app/features/chat/cubit/chat_room/chat_room_state.dart';
import 'package:social_media_app/features/chat/widgets/chat_bubble.dart';
import 'package:social_media_app/features/chat/widgets/chat_input_field.dart';
import 'package:social_media_app/features/profile/views/profile_screen.dart';

class ChatRoomScreen extends StatelessWidget {
  final ChatModel? chat;
  final String? otherUserId;

  const ChatRoomScreen({
    super.key,
    this.chat,
    this.otherUserId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatRoomCubit()
        ..initChatRoom(
          chat: chat,
          otherUserId: otherUserId,
        ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: BlocBuilder<ChatRoomCubit, ChatRoomState>(
            builder: (context, state) {
              if (state is ChatRoomSuccess) {
                final otherUser = state.chat.otherUser;
                return AppBar(
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  backgroundColor: AppColors.white,
                  leadingWidth: 40,
                  leading: IconButton(
                    padding: const EdgeInsets.only(left: 8),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  titleSpacing: 8,
                  title: GestureDetector(
                    onTap: () {
                      if (otherUser != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileScreen(userId: otherUser.id),
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        UserAvatar(
                          imageUrl: otherUser?.imageUrl,
                          name: otherUser?.name ?? 'User',
                          radius: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                otherUser?.name ?? 'User',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                              ),
                              if (otherUser?.title != null &&
                                  otherUser!.title!.isNotEmpty) ...[
                                Text(
                                  otherUser.title!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.darkGrey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.info_outline_rounded, color: AppColors.black),
                      onPressed: () {
                        if (otherUser != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(userId: otherUser.id),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                );
              }
              return AppBar(
                backgroundColor: AppColors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              );
            },
          ),
        ),
        body: BlocBuilder<ChatRoomCubit, ChatRoomState>(
          builder: (context, state) {
            if (state is ChatRoomLoading) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (state is ChatRoomFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ChatRoomCubit>().initChatRoom(
                                chat: chat,
                                otherUserId: otherUserId,
                              );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ChatRoomSuccess) {
              final messages = state.messages;
              final reversedMessages = messages.reversed.toList();
              final cubit = context.read<ChatRoomCubit>();

              return Column(
                children: [
                  const Divider(height: 1, color: Color(0xffF2F2F7)),
                  Expanded(
                    child: messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 48,
                                  color: AppColors.darkGrey.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Say hello to ${state.chat.otherUser?.name ?? 'User'}!',
                                  style: TextStyle(
                                    color: AppColors.darkGrey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            reverse: true, // Auto-scrolls and keeps bottom focus
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            itemCount: reversedMessages.length,
                            itemBuilder: (context, index) {
                              final message = reversedMessages[index];
                              final isMe = message.senderId == state.currentUserId;
                              return ChatBubble(
                                message: message,
                                isMe: isMe,
                              );
                            },
                          ),
                  ),
                  ChatInputField(
                    onSend: (text) => cubit.sendMessage(text),
                    onImageSelected: (filePath, fileName) =>
                        cubit.sendImage(filePath, fileName),
                    isSending: state.isSending,
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
