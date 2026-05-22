import 'package:flutter/material.dart';
import 'package:social_media_app/core/theme/app_colors.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: AppColors.black),
                  iconSize: 30,
                ),
                Text(
                  "Create Post",
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: AppColors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
