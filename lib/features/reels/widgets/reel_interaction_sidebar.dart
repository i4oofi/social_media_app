import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/cubit/posts_cubit/posts_cubit.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/reels/cubit/reels_cubit.dart';
import 'package:social_media_app/features/home/widgets/comments_sheet.dart';

class ReelInteractionSidebar extends StatelessWidget {
  final PostModel reel;

  ReelInteractionSidebar({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Like Button
        _InteractionButton(
          icon: reel.isLiked ? Icons.favorite : Icons.favorite_border,
          color: reel.isLiked ? AppColors.primaryColor : Colors.white,
          label: reel.likes?.length.toString() ?? '0',
          onTap: () {
            context.read<ReelsCubit>().toggleLike(reel.id);
          },
        ),
        SizedBox(height: 20.h),
        // Comment Button
        _InteractionButton(
          icon: Icons.comment_outlined,
          color: Colors.white,
          label: reel.commentCount?.toString() ?? '0',
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              backgroundColor: Theme.of(context).cardColor,
              builder: (sheetContext) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: MediaQuery.of(context).size.width,
                  child: SafeArea(
                    child: BlocProvider.value(
                      value: context.read<PostsCubit>(),
                      child: CommentsSheet(post: reel),
                    ),
                  ),
                );
              },
            );
          },
        ),
        SizedBox(height: 20.h),
        // Share Button
        _InteractionButton(
          icon: Icons.share_outlined,
          color: Colors.white,
          label: 'Share',
          onTap: () {
            // TODO: Implement share action
          },
        ),
        SizedBox(height: 40.h),
      ],
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _InteractionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 30.h),
          SizedBox(height: 5.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
