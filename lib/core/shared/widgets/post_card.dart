import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/core/cubit/posts_cubit/posts_cubit.dart';
import 'package:social_media_app/core/shared/widgets/user_avatar.dart';
import 'package:social_media_app/core/shared/widgets/custom_video_player.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/features/home/widgets/comments_sheet.dart';
import 'package:social_media_app/features/profile/views/profile_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';
import 'package:social_media_app/core/route/app_routes.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.isDetailView = false});
  final PostModel post;
  final bool isDetailView;

  bool _hasVideo() {
    return post.video != null && post.video!.isNotEmpty;
  }

  void _showDeleteDialog(BuildContext context, PostModel post) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<HomeCubit>().deletePost(post.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, PostModel post) {
    final controller = TextEditingController(text: post.text);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Post'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'What is on your mind?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newText = controller.text.trim();
              if (newText.isNotEmpty) {
                Navigator.pop(dialogContext);
                context.read<HomeCubit>().editPost(post.id, newText);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPostImage = post.imageUrl != null && post.imageUrl!.isNotEmpty;
    final hasPostVideo = _hasVideo();
    final postsCubit = context.read<PostsCubit>();
    final size = MediaQuery.of(context).size;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isOwner = currentUserId != null && currentUserId == post.authorId;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen(userId: post.authorId),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      UserAvatar(
                        imageUrl: post.authorProfileImage,
                        name: post.authorName ?? '',
                        radius: 20,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.authorName ?? 'No Name',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat(
                              "h:mm a",
                            ).format(DateTime.parse(post.createdAt)).toString(),
                            style: Theme.of(context).textTheme.labelMedium!
                                .copyWith(color: AppColors.darkGrey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isOwner)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditDialog(context, post);
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, post);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Edit Post'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Delete Post',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert_rounded),
                  ),
              ],
            ),

            InkWell(
              onTap: isDetailView
                  ? null
                  : () {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed(AppRoutes.postDetailScreen, arguments: post);
                    },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  if (hasPostImage) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: post.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        placeholder: (context, url) => Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[100],
                          child: const Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (hasPostVideo) ...[
                    CustomVideoPlayer(videoUrl: post.video!),
                    const SizedBox(height: 12),
                  ],
                  Text(post.text, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                BlocBuilder<PostsCubit, PostsState>(
                  bloc: postsCubit,
                  buildWhen: (previous, current) {
                    return (current is PostLiking &&
                            current.postId == post.id) ||
                        (current is PostLiked && current.postId == post.id) ||
                        (current is PostLikeError && current.postId == post.id);
                  },
                  builder: (context, state) {
                    final isOptimisticLiked = state is PostLiked
                        ? state.isLiked
                        : state is PostLiking
                        ? !post.isLiked
                        : post.isLiked;

                    final optimisticLikesCount = state is PostLiked
                        ? state.likesCount
                        : state is PostLiking
                        ? (post.isLiked
                              ? (post.likes?.length ?? 1) - 1
                              : (post.likes?.length ?? 0) + 1)
                        : post.likes?.length ?? 0;

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: state is PostLiking
                              ? null
                              : () async {
                                  await postsCubit.likePost(post.id);
                                },
                          icon: Icon(
                            isOptimisticLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isOptimisticLiked
                                ? AppColors.primaryColor
                                : null,
                          ),
                        ),
                        Text(optimisticLikesCount.toString()),
                      ],
                    );
                  },
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      backgroundColor: Theme.of(context).cardColor,
                      builder: (context) {
                        return SizedBox(
                          height: size.height * 0.8,
                          width: size.width,
                          child: SafeArea(
                            child: BlocProvider.value(
                              value: postsCubit,
                              child: CommentsSheet(post: post),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.comment_outlined, size: 20),
                ),
                Text('${post.commentCount}'),
                const Spacer(),
                BlocBuilder<PostsCubit, PostsState>(
                  bloc: postsCubit,
                  buildWhen: (previous, current) => current is SavedPostsLoaded,
                  builder: (context, state) {
                    final isSaved = postsCubit.savedPostIds.contains(post.id);
                    return IconButton(
                      onPressed: () {
                        postsCubit.toggleSavePost(post.id);
                      },
                      icon: Icon(
                        isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: isSaved ? AppColors.primaryColor : null,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
