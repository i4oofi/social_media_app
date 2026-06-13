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
    // Fetch the detailed saved posts from DB
    context.read<PostsCubit>().fetchSavedPostsDetails();
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
      body: BlocBuilder<PostsCubit, PostsState>(
        buildWhen: (previous, current) => 
          current is FetchingSavedPostsDetails ||
          current is SavedPostsDetailsFetched ||
          current is SavedPostsDetailsError,
        builder: (context, postsState) {
          if (postsState is FetchingSavedPostsDetails) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (postsState is SavedPostsDetailsError) {
            return Center(
              child: Text(
                'Failed to load posts: ${postsState.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (postsState is SavedPostsDetailsFetched) {
            final savedPosts = postsState.savedPosts;

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
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
