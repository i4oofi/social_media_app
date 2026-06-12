import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/cubit/posts_cubit/posts_cubit.dart';
import 'package:social_media_app/core/shared/widgets/post_card.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';
import 'package:social_media_app/features/home/models/post_model.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  @override
  void initState() {
    super.initState();
    // Make sure we have the latest posts loaded
    final homeCubit = context.read<HomeCubit>();
    if (homeCubit.state is! PostLoaded) {
      homeCubit.fetchPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved Posts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, homeState) {
          if (homeState is PostLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          List<PostModel> allPosts = [];
          if (homeState is PostLoaded) {
            allPosts = homeState.posts;
          } else if (homeState is PostError) {
            return Center(
              child: Text(
                'Failed to load posts: ${homeState.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return BlocBuilder<PostsCubit, PostsState>(
            builder: (context, postsState) {
              final savedIds = context.read<PostsCubit>().savedPostIds;
              final savedPosts = allPosts.where((post) => savedIds.contains(post.id)).toList();

              if (savedPosts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border_rounded,
                        size: 64,
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey[600]
                            : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No saved posts yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Posts you bookmark will appear here',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey[500]
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: savedPosts.length,
                itemBuilder: (context, index) {
                  return PostCard(post: savedPosts[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}
