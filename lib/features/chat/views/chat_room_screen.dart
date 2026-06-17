import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  const ChatRoomScreen({super.key, this.chat, this.otherUserId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) =>
          ChatRoomCubit()..initChatRoom(chat: chat, otherUserId: otherUserId),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: BlocBuilder<ChatRoomCubit, ChatRoomState>(
            builder: (context, state) {
              if (state is ChatRoomSuccess) {
                final otherUser = state.chat.otherUser;
                return AppBar(
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  leadingWidth: 40,
                  leading: IconButton(
                    padding: EdgeInsets.only(left: 8.w),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: theme.iconTheme.color,
                    ),
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
                          radius: 18.r,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                otherUser?.name ?? 'User',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (otherUser?.title != null &&
                                  otherUser!.title!.isNotEmpty) ...[
                                Text(
                                  otherUser.title!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11.sp,
                                    color: theme.hintColor,
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
                      icon: Icon(
                        Icons.info_outline_rounded,
                        color: theme.iconTheme.color,
                      ),
                      onPressed: () {
                        if (otherUser != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProfileScreen(userId: otherUser.id),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                );
              }
              return AppBar(
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: theme.iconTheme.color,
                  ),
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
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.red,
                        size: 48.h,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        state.errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.red),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ChatRoomCubit>().initChatRoom(
                            chat: chat,
                            // ignore: avoid_redundant_argument_values
                            otherUserId: otherUserId,
                          );
                        },
                        child: Text('Retry'),
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
                  Divider(
                    height: 1.h,
                    color: theme.dividerColor.withOpacity(0.5),
                  ),
                  Expanded(
                    child: messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 48.h,
                                  color: theme.hintColor,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'Say hello to ${state.chat.otherUser?.name ?? 'User'}!',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.hintColor,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            reverse: true,
                            padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                            itemCount: reversedMessages.length,
                            itemBuilder: (context, index) {
                              final message = reversedMessages[index];
                              final isMe =
                                  message.senderId == state.currentUserId;
                              return ChatBubble(message: message, isMe: isMe);
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
