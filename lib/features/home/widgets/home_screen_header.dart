import 'package:flutter/material.dart';
import 'package:social_media_app/core/app_assets.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
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
              height: 50,
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search_rounded, color: AppColors.black),
              iconSize: 30,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none_outlined,
                color: AppColors.black,
              ),
              iconSize: 30,
            ),
            IconButton(
              onPressed: () {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamed(AppRoutes.inboxScreen);
              },
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.black,
              ),
              iconSize: 30,
            ),
          ],
        ),
      ],
    );
  }
}
