import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/cubit/posts_cubit/posts_cubit.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/core/models/comment_model.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/features/profile/views/profile_screen.dart';
import 'package:social_media_app/core/shared/widgets/animated_empty_state.dart';

class CommentSection extends StatelessWidget {
  final PostModel post;
  const CommentSection({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostsCubit, PostsState>(
      buildWhen: (previous, current) =>
          current is CommentsFetching ||
          current is CommentsFetched ||
          current is CommentsError,
      builder: (context, state) {
        if (state is CommentsFetching) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is CommentsFetched) {
          final comments = state.comments;
          final parentComments = comments
              .where((c) => c.parentId == null)
              .toList();
          if (parentComments.isEmpty && comments.isEmpty) {
            return Center(
              child: AnimatedEmptyState(
                icon: Icons.chat_bubble_outline,
                title: 'No comments yet',
                subtitle: 'Be the first to share your thoughts!',
              ),
            );
          }
          return ListView.separated(
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemCount: parentComments.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final parentComment = parentComments[index];
              final replies = comments
                  .where((c) => c.parentId == parentComment.id)
                  .toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommentWidget(comment: parentComment, index: index),
                  if (replies.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: 48.w, top: 8.h),
                      child: ListView.separated(
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 8.h),
                        itemCount: replies.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, rIndex) {
                          return CommentWidget(
                            comment: replies[rIndex],
                            isReply: true,
                            index: index + rIndex + 1,
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          );
        }
        if (state is CommentsError) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Center(
              child: Text(state.error, style: TextStyle(color: Colors.red)),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class CommentWidget extends StatelessWidget {
  final CommentModel comment;
  final bool isReply;
  final int index;

  const CommentWidget({
    super.key,
    required this.comment,
    this.isReply = false,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = comment.image != null && comment.image!.isNotEmpty;
    final hasAuthorImage =
        comment.authorImage != null && comment.authorImage!.isNotEmpty;
    final avatarSize = isReply ? 28.w : 36.w;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final delay = (index * 0.1).clamp(0.0, 0.5);
        final adjustedValue = ((value - delay) / (1 - delay)).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, 20 * (1 - adjustedValue)),
          child: Opacity(opacity: adjustedValue, child: child),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(context, hasAuthorImage, avatarSize),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.5),
                      border: Border.all(
                        color: AppColors.primaryColor.withValues(alpha: 0.2),
                        width: 1.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16.r),
                        bottomLeft: Radius.circular(16.r),
                        bottomRight: Radius.circular(16.r),
                        topLeft: isReply ? Radius.circular(16.r) : Radius.zero,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ProfileScreen(
                                        userId: comment.authorId,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  comment.authorName ?? 'Anonymous',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              _formatDateTime(comment.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withOpacity(0.6),
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          comment.text,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.9),
                            height: 1.3,
                          ),
                        ),
                        if (hasImage) ...[
                          SizedBox(height: 10.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: CachedNetworkImage(
                              imageUrl: comment.image!,
                              fit: BoxFit.cover,
                              maxHeightDiskCache: 600,
                              placeholder: (context, url) => Container(
                                height: 160.h,
                                width: double.infinity,
                                color: theme.colorScheme.surfaceVariant,
                                child: Center(
                                  child: SizedBox(
                                    height: 24.h,
                                    width: 24.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 160.h,
                                width: double.infinity,
                                color: theme.colorScheme.surfaceVariant,
                                child: Icon(Icons.broken_image, size: 32.h),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4.h, left: 8.w),
                    child: Row(
                      children: [
                        BlocBuilder<PostsCubit, PostsState>(
                          buildWhen: (previous, current) {
                            return (current is CommentLiking &&
                                    current.commentId == comment.id) ||
                                (current is CommentLiked &&
                                    current.commentId == comment.id) ||
                                (current is CommentLikeError &&
                                    current.commentId == comment.id);
                          },
                          builder: (context, state) {
                            final isOptimisticLiked = state is CommentLiked
                                ? state.isLiked
                                : state is CommentLiking
                                ? !comment.isLiked
                                : comment.isLiked;

                            final optimisticLikesCount = state is CommentLiked
                                ? state.likesCount
                                : state is CommentLiking
                                ? (comment.isLiked
                                      ? (comment.likes?.length ?? 1) - 1
                                      : (comment.likes?.length ?? 0) + 1)
                                : comment.likes?.length ?? 0;

                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: state is CommentLiking
                                      ? null
                                      : () {
                                          context
                                              .read<PostsCubit>()
                                              .likeComment(comment.id);
                                        },
                                  child: Text(
                                    'Like',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          fontWeight: isOptimisticLiked
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isOptimisticLiked
                                              ? AppColors.primaryColor
                                              : theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                        ),
                                  ),
                                ),
                                if (optimisticLikesCount > 0) ...[
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.favorite,
                                    size: 12.h,
                                    color: isOptimisticLiked
                                        ? AppColors.primaryColor
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    optimisticLikesCount.toString(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                        SizedBox(width: 16.w),
                        InkWell(
                          onTap: () {
                            context.read<PostsCubit>().setReplyingTo(comment);
                          },
                          child: Text(
                            'Reply',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool hasAuthorImage, double size) {
    final theme = Theme.of(context);
    final nameInitials =
        (comment.authorName != null && comment.authorName!.isNotEmpty)
        ? comment.authorName!.substring(0, 1).toUpperCase()
        : '?';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: comment.authorId),
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryColor.withValues(alpha: 0.5),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1.w,
          ),
        ),
        child: ClipOval(
          child: hasAuthorImage
              ? CachedNetworkImage(
                  imageUrl: comment.authorImage!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: SizedBox(
                      height: 16.h,
                      width: 16.w,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Text(
                      nameInitials,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    nameInitials,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  String _formatDateTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp).toLocal();
      final difference = DateTime.now().difference(dateTime);
      if (difference.inMinutes < 1) {
        return 'just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (_) {
      return '';
    }
  }
}
