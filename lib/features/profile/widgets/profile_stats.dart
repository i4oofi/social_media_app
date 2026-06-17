import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          width: 1.w,
          color: AppColors.grey,
        ),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: Row(
          children: [
            Expanded(
              child: ProfileStatItem(
                number: userData.postsCount ?? 0,
                label: 'Posts',
              ),
            ),
            SizedBox(
              height: 30.h,
              child: VerticalDivider(color: AppColors.grey, thickness: 0.5),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: ProfileStatItem(
                number: userData.followersCount ?? 0,
                label: 'Followers',
              ),
            ),
            SizedBox(width: 8.w),
            SizedBox(
              height: 30.h,
              child: VerticalDivider(color: AppColors.grey, thickness: 0.5),
            ),
            SizedBox(width: 8.w),
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
        SizedBox(height: 4.h),
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
