import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/cubit/posts_cubit/posts_cubit.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/core/shared/widgets/user_avatar.dart';
import 'package:social_media_app/core/shared/widgets/shimmer_loading.dart';

class LikeSection extends StatelessWidget {
  final PostModel post;
  const LikeSection({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final postsCubit = context.read<PostsCubit>();
    return BlocBuilder<PostsCubit, PostsState>(
      bloc: postsCubit,
      buildWhen: (previous, current) {
        return current is FetchingLikersDetails ||
            current is LikersDetailsFetched ||
            current is FetchingLikersDetailsError;
      },
      builder: (context, state) {
        if (state is LikersDetailsFetched) {
          final likes = state.likersDetails;
          if (likes.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'No likes yet',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            );
          }
          return _buildLikesRow(context, likes);
        } else if (state is FetchingLikersDetailsError) {
          return const SizedBox.shrink();
        }
        return _buildLoadingState();
      },
    );
  }

  Widget _buildLoadingState() {
    return Row(
      children: [
        ...List.generate(
          3,
          (index) => Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ShimmerBox(
              width: 16.r * 2,
              height: 16.r * 2,
              isCircle: true,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        ShimmerBox(width: 60.w, height: 14.h, borderRadius: 4),
      ],
    );
  }

  Widget _buildLikesRow(BuildContext context, List likes) {
    const int maxVisible = 5;
    final int visibleCount = likes.length > maxVisible
        ? maxVisible
        : likes.length;
    final double avatarRadius = 16.r;
    final double overlap = avatarRadius * 1.2;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Row(
              children: [
                SizedBox(
                  width: (visibleCount - 1) * overlap + (avatarRadius * 2),
                  height: avatarRadius * 2,
                  child: Stack(
                    children: List.generate(visibleCount, (index) {
                      final like = likes[index];
                      return Positioned(
                        left: index * overlap,
                        child: UserAvatar(
                          imageUrl: like.imageUrl,
                          name: like.name,
                          radius: avatarRadius,
                          showBorder: true,
                          borderColor: Theme.of(
                            context,
                          ).scaffoldBackgroundColor,
                          borderWidth: 2.0,
                        ),
                      );
                    }).reversed.toList(),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    '${likes.length} likes',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
