import 'package:flutter/material.dart';
import 'package:social_media_app/features/home/widgets/home_screen_header.dart';
import 'package:social_media_app/features/home/widgets/post_writing_card.dart';
import 'package:social_media_app/features/home/widgets/stories_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
          ],
        ),
      ),
    );
  }
}
