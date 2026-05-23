import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';
import 'package:social_media_app/features/home/widgets/home_screen_header.dart';
import 'package:social_media_app/features/home/widgets/post_writing_card.dart';
import 'package:social_media_app/features/home/widgets/posts_section.dart';
import 'package:social_media_app/features/home/widgets/stories_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = HomeCubit();
        cubit.fetchStories();
        cubit.fetchPosts();
        return cubit;
      },
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const HomeScreenHeader(),
                const SizedBox(height: 16),
                const PostWritingCard(),
                const SizedBox(height: 24),
                const StoriesSection(),
                const PostsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
