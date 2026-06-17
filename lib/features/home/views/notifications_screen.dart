import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/core/cubit/notification_cubit/notification_cubit.dart';
import 'package:social_media_app/core/models/notification_model.dart';
import 'package:social_media_app/core/shared/widgets/user_avatar.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';
import 'package:social_media_app/features/profile/views/profile_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().fetchNotifications();
  }

  String _getNotificationMessage(String type) {
    switch (type) {
      case 'like':
        return 'liked your post.';
      case 'comment':
        return 'commented on your post.';
      case 'follow':
        return 'started following you.';
      default:
        return 'interacted with your account.';
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite_rounded;
      case 'comment':
        return Icons.comment_rounded;
      case 'follow':
        return Icons.person_add_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationIconColor(String type) {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.blue;
      case 'follow':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read
    context.read<NotificationCubit>().markAsRead(notification.id);

    // Navigate based on type
    if ((notification.type == 'like' || notification.type == 'comment') && notification.postId != null) {
      // Find the post in HomeCubit state to display details, or fetch it
      final homeState = context.read<HomeCubit>().state;
      if (homeState is PostLoaded) {
        final post = homeState.posts.firstWhere(
          (p) => p.id == notification.postId,
          orElse: () => throw Exception('Post not found'),
        );
        Navigator.pushNamed(context, AppRoutes.postDetailScreen, arguments: post);
      } else {
        // Fallback: navigate to home/feed
        Navigator.pop(context);
      }
    } else if (notification.type == 'follow') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(userId: notification.senderId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            icon: Icon(Icons.done_all_rounded),
            onPressed: () {
              context.read<NotificationCubit>().markAllAsRead();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<NotificationCubit>().fetchNotifications(),
        child: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationsLoading) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (state is NotificationsError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0.w),
                  child: Text(
                    'Error: ${state.error}',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state is NotificationsLoaded) {
              final notifications = state.notifications;

              if (notifications.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 64.h,
                            color: theme.brightness == Brightness.dark
                                ? Colors.grey[600]
                                : Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No notifications yet',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Interactions on your posts will appear here',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey[500]
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final timeText = notification.createdAt.isNotEmpty
                      ? DateFormat('MMM d, h:mm a').format(DateTime.parse(notification.createdAt))
                      : '';

                  return InkWell(
                    onTap: () => _handleNotificationTap(notification),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      color: notification.isRead
                          ? Colors.transparent
                          : AppColors.primaryColor.withValues(alpha: 0.06),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              UserAvatar(
                                imageUrl: notification.senderImageUrl,
                                name: notification.senderName ?? 'User',
                                radius: 24.r,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.scaffoldBackgroundColor,
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(2.w),
                                child: Icon(
                                  _getNotificationIcon(notification.type),
                                  size: 14.h,
                                  color: _getNotificationIconColor(notification.type),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: theme.textTheme.bodyLarge?.color,
                                      fontSize: 14.sp,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: notification.senderName ?? 'Someone',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const TextSpan(text: ' '),
                                      TextSpan(
                                        text: _getNotificationMessage(notification.type),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  timeText,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8.w,
                              height: 8.h,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
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
    );
  }
}
