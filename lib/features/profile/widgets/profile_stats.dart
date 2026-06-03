import 'package:flutter/material.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';

class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({super.key, required this.userData});
  final UserData userData;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          style: BorderStyle.solid,
          width: 1,
          color: AppColors.grey,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: ProfileStatItem(
                number: userData.postsCount ?? 0,
                label: 'Posts',
              ),
            ),
            SizedBox(
              height: 30,
              child: VerticalDivider(color: AppColors.grey, thickness: 0.5),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ProfileStatItem(
                number: userData.followersCount ?? 0,
                label: 'Followers',
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 30,
              child: VerticalDivider(color: AppColors.grey, thickness: 0.5),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ProfileStatItem(
                number: userData.followingCount ?? 0,
                label: 'Following',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileStatItem extends StatelessWidget {
  const ProfileStatItem({super.key, required this.number, required this.label});
  final num number;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number.toString(),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: AppColors.darkGrey),
        ),
      ],
    );
  }
}
