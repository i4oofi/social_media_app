import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/core/cubit/posts_cubit/posts_cubit.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/features/home/widgets/comments_sheet.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});
  final PostModel post;
  @override
  Widget build(BuildContext context) {
    final hasProfileImage =
        post.authorProfileImage != null && post.authorProfileImage!.isNotEmpty;
    final hasPostImage = post.imageUrl != null && post.imageUrl!.isNotEmpty;
    final postsCubit = context.read<PostsCubit>();
    final size = MediaQuery.of(context).size;

    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.babyBlue15,
                  foregroundColor: AppColors.primaryColor,
                  backgroundImage: hasProfileImage
                      ? CachedNetworkImageProvider(post.authorProfileImage!)
                      : null,
                  child: !hasProfileImage ? const Icon(Icons.person) : null,
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
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              post.text,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(color: AppColors.black),
            ),
            const SizedBox(height: 12),
            BlocBuilder<PostsCubit, PostsState>(
              bloc: postsCubit,
              buildWhen: (previous, current) {
                return (current is PostLiking && current.postId == post.id) ||
                    (current is PostLiked && current.postId == post.id) ||
                    (current is PostLikeError && current.postId == post.id);
              },
              builder: (context, state) {
                return Row(
                  children: [
                    state is PostLiking
                        ? const SizedBox(
                            width: 48,
                            height: 48,
                            child: Padding(
                              padding: EdgeInsets.all(14.0),
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : IconButton(
                            onPressed: () async {
                              await postsCubit.likePost(post.id);
                            },
                            icon: Icon(
                              state is PostLiked
                                  ? state.isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border
                                  : post.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: state is PostLiked
                                  ? state.isLiked
                                        ? AppColors.primaryColor
                                        : null
                                  : post.isLiked
                                  ? AppColors.primaryColor
                                  : null,
                            ),
                          ),
                    Text(
                      state is PostLiked
                          ? state.likesCount.toString()
                          : '${post.likes?.length ?? 0}',
                    ),
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useRootNavigator: true,
                          backgroundColor: AppColors.white,
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
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
