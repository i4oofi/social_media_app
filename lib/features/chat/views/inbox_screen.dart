import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/core/shared/widgets/shimmer_loading.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/core/shared/widgets/user_avatar.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/chat/cubit/inbox/inbox_cubit.dart';
import 'package:social_media_app/features/chat/cubit/inbox/inbox_state.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InboxCubit()..listenToInbox(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: Text(
            'Messages',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  letterSpacing: -0.5,
                ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.black),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: AppColors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.black),
                  decoration: InputDecoration(
                    hintText: 'Search chats...',
                    hintStyle: TextStyle(color: AppColors.darkGrey),
                    prefixIcon: const Icon(Icons.search, color: AppColors.black),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.black),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            
            // Inbox Chats List
            Expanded(
              child: BlocBuilder<InboxCubit, InboxState>(
                builder: (context, state) {
                  if (state is InboxLoading) {
                    return ListView.separated(
                      itemCount: 7,
                      separatorBuilder: (_, index) => const Divider(
                        height: 1,
                        indent: 84,
                        endIndent: 20,
                        color: Color(0xffF2F2F7),
                      ),
                      itemBuilder: (_, __) => const InboxChatShimmer(),
                    );
                  }
                  
                  if (state is InboxFailure) {
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
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is InboxSuccess) {
                    final chats = state.chats;
                    
                    // Filter chats by query
                    final filteredChats = chats.where((chat) {
                      final nameMatch = (chat.otherUser?.name ?? '')
                          .toLowerCase()
                          .contains(_searchQuery);
                      return nameMatch;
                    }).toList();

                    if (filteredChats.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 64,
                              color: AppColors.darkGrey.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No matching chats'
                                  : 'No conversations yet',
                              style: TextStyle(
                                color: AppColors.darkGrey,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  // Simply pop back, since user can use Discover tab to find users to chat with
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Discover People',
                                  style: TextStyle(color: AppColors.white),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: filteredChats.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        indent: 84,
                        endIndent: 20,
                        color: Color(0xffF2F2F7),
                      ),
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        final otherUser = chat.otherUser;
                        final unreadCount = state.unreadCounts[chat.id] ?? 0;
                        final hasUnread = unreadCount > 0;
                        final lastMsgSenderIsMe = chat.lastMessageSenderId == state.currentUserId;
                        
                        String messagePreview = '';
                        if (chat.lastMessage != null) {
                          if (chat.lastMessage!.startsWith('http') &&
                              (chat.lastMessage!.contains('chat_attachments') ||
                                  chat.lastMessage!.contains('/storage/v1/object/public'))) {
                            messagePreview = lastMsgSenderIsMe ? 'You sent a photo' : 'Sent a photo';
                          } else {
                            messagePreview = chat.lastMessage!;
                          }
                        } else {
                          messagePreview = 'Start a conversation';
                        }

                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.chatRoomScreen,
                              arguments: {'chat': chat},
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                // Avatar
                                UserAvatar(
                                  imageUrl: otherUser?.imageUrl,
                                  name: otherUser?.name ?? 'User',
                                  radius: 28,
                                  showBorder: hasUnread,
                                  borderColor: AppColors.primaryColor,
                                  borderWidth: 2,
                                ),
                                const SizedBox(width: 12),
                                
                                // Info Block
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            otherUser?.name ?? 'User',
                                            style: TextStyle(
                                              fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                                              fontSize: 16,
                                              color: AppColors.black,
                                            ),
                                          ),
                                          if (chat.lastMessageTime != null)
                                            Text(
                                              _formatTime(chat.lastMessageTime!),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: hasUnread ? AppColors.primaryColor : AppColors.darkGrey,
                                                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              messagePreview,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: hasUnread ? AppColors.black : AppColors.darkGrey,
                                                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          if (hasUnread) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: const BoxDecoration(
                                                color: AppColors.primaryColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                '$unreadCount',
                                                style: const TextStyle(
                                                  color: AppColors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
