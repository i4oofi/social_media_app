import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_media_app/core/app_assets.dart';
import 'package:social_media_app/core/route/app_routes.dart';

class HomeScreenHeader extends StatelessWidget {
  const HomeScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              AppAssets.appLogo,
              width: size.width * 0.50,
              height: 50.h,
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.search_rounded),
              iconSize: 30.r,
            ),
            IconButton(
              onPressed: () {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamed(AppRoutes.notifications);
              },
              icon: Icon(Icons.notifications_none_outlined),
              iconSize: 30.r,
            ),
            IconButton(
              onPressed: () {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamed(AppRoutes.inboxScreen);
              },
              icon: Icon(Icons.chat_bubble_outline_rounded),
              iconSize: 30.r,
            ),
          ],
        ),
      ],
    );
  }
}
