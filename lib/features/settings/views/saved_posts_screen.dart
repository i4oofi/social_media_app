import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/cubit/posts_cubit/posts_cubit.dart';
import 'package:social_media_app/core/shared/widgets/animated_empty_state.dart';
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
        title: Text(
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
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (postsState is SavedPostsDetailsFetched) {
            final savedPosts = postsState.savedPosts;

            if (savedPosts.isEmpty) {
              return const AnimatedEmptyState(
                icon: Icons.bookmark_border_rounded,
                title: 'No saved posts yet',
                subtitle: 'Posts you bookmark will appear here',
                // imagePath: 'assets/images/empty_saved_posts.gif', // uncomment when GIF is added
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(8.w),
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
