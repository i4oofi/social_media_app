import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_media_app/core/app_assets.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/core/cubit/notification_cubit/notification_cubit.dart';
import 'package:social_media_app/features/chat/cubit/inbox/inbox_cubit.dart';
import 'package:social_media_app/features/chat/cubit/inbox/inbox_state.dart';

class HomeScreenHeader extends StatefulWidget {
  const HomeScreenHeader({super.key});

  @override
  State<HomeScreenHeader> createState() => _HomeScreenHeaderState();
}

class _HomeScreenHeaderState extends State<HomeScreenHeader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationCubit>().fetchNotifications();
      context.read<InboxCubit>().listenToInbox();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset(AppAssets.appLogo, width: 50.w, height: 28.h),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.search_rounded),
              iconSize: 30.r,
            ),
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                int unreadCount = 0;
                if (state is NotificationsLoaded) {
                  unreadCount = state.notifications
                      .where((n) => !n.isRead)
                      .length;
                }
                return IconButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamed(AppRoutes.notifications);
                  },
                  icon: Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text(
                      unreadCount.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppColors.primaryColor,
                    child: Icon(Icons.notifications_none_outlined),
                  ),
                  iconSize: 30.r,
                );
              },
            ),
            BlocBuilder<InboxCubit, InboxState>(
              builder: (context, state) {
                int unreadChatsCount = 0;
                if (state is InboxSuccess) {
                  unreadChatsCount = state.totalUnreadCount;
                }
                return IconButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamed(AppRoutes.inboxScreen);
                  },
                  icon: Badge(
                    isLabelVisible: unreadChatsCount > 0,
                    label: Text(
                      unreadChatsCount.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppColors.primaryColor,
                    child: Icon(Icons.chat_bubble_outline_rounded),
                  ),
                  iconSize: 30.r,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
