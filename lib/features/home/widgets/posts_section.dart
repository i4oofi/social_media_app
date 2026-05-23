import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';
import 'package:social_media_app/features/home/models/post_model.dart';

class PostsSection extends StatelessWidget {
  const PostsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: cubit,
      buildWhen: (previous, current) =>
          current is PostLoading ||
          current is PostLoaded ||
          current is PostError,
      builder: (context, state) {
        if (state is PostLoading) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (state is PostLoaded) {
          return ListView.builder(
            itemCount: state.posts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return PostCard(post: state.posts[index]);
            },
          );
        } else if (state is PostError) {
          return Center(child: Text(state.error));
        }
        return const Center(child: Text('No Posts'));
      },
    );
  }
}

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});
  final PostModel post;
  @override
  Widget build(BuildContext context) {
    final hasProfileImage =
        post.authorProfileImage != null && post.authorProfileImage!.isNotEmpty;
    final hasPostImage = post.imageUrl != null && post.imageUrl!.isNotEmpty;

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
                  errorWidget: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
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
            Row(
              children: [
                const Icon(Icons.favorite_border, size: 20),
                const SizedBox(width: 4),
                Text('${post.likes?.length ?? 0}'),
                const SizedBox(width: 16),
                const Icon(Icons.comment_outlined, size: 20),
                const SizedBox(width: 4),
                Text('${post.comments?.length ?? 0}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
