import 'package:flutter/material.dart';
import 'package:social_media_app/core/app_assets.dart';
import 'package:social_media_app/core/theme/app_colors.dart';

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
            IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu_rounded, color: AppColors.black),
              iconSize: 28,
            ),
            const SizedBox(width: 4),
            Image.asset(AppAssets.appLogo, width: size.width * 0.42, height: 50),
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
          ],
        ),
      ],
    );
  }
}
