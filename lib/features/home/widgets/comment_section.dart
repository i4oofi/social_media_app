import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/cubit/posts_cubit/posts_cubit.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/core/models/comment_model.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/features/profile/views/profile_screen.dart';

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
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is CommentsFetched) {
          final comments = state.comments;
          final parentComments = comments
              .where((c) => c.parentId == null)
              .toList();
          if (parentComments.isEmpty && comments.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 40,
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No comments yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Be the first to share your thoughts!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 12),
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
                  CommentWidget(comment: parentComment),
                  if (replies.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 48.0, top: 8.0),
                      child: ListView.separated(
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemCount: replies.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, rIndex) {
                          return CommentWidget(
                            comment: replies[rIndex],
                            isReply: true,
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
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                state.error,
                style: const TextStyle(color: Colors.red),
              ),
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
  const CommentWidget({super.key, required this.comment, this.isReply = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = comment.image != null && comment.image!.isNotEmpty;
    final hasAuthorImage =
        comment.authorImage != null && comment.authorImage!.isNotEmpty;
    final avatarSize = isReply ? 28.0 : 36.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // Author Avatar with placeholder fallback
          _buildAvatar(context, hasAuthorImage, avatarSize),

          // Comment Content Bubble
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.babyBlue5.withOpacity(0.5),
                      borderRadius: BorderRadius.only(
                        topRight: const Radius.circular(16),
                        bottomLeft: const Radius.circular(16),
                        bottomRight: const Radius.circular(16),
                        topLeft: isReply
                            ? const Radius.circular(16)
                            : const Radius.circular(0),
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
                            const SizedBox(width: 8),
                            Text(
                              _formatDateTime(comment.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withOpacity(0.6),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          comment.text,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.9),
                            height: 1.3,
                          ),
                        ),
                        if (hasImage) ...[
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: comment.image!,
                              fit: BoxFit.cover,
                              maxHeightDiskCache: 600,
                              placeholder: (context, url) => Container(
                                height: 160,
                                width: double.infinity,
                                color: theme.colorScheme.surfaceVariant,
                                child: const Center(
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 160,
                                width: double.infinity,
                                color: theme.colorScheme.surfaceVariant,
                                child: const Icon(Icons.broken_image, size: 32),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8),
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
                                        context.read<PostsCubit>().likeComment(
                                          comment.id,
                                        );
                                      },
                                child: Text(
                                  'Like',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: isOptimisticLiked
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isOptimisticLiked
                                        ? AppColors.primaryColor
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              if (optimisticLikesCount > 0) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.favorite,
                                  size: 12,
                                  color: isOptimisticLiked
                                      ? AppColors.primaryColor
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 2),
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
                      const SizedBox(width: 16),
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
          color: theme.colorScheme.primaryContainer,
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: ClipOval(
          child: hasAuthorImage
              ? CachedNetworkImage(
                  imageUrl: comment.authorImage!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: SizedBox(
                      height: 16,
                      width: 16,
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
