import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';
import 'package:social_media_app/features/home/models/story_model.dart';

class StoriesSection extends StatelessWidget {
  const StoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCubit = BlocProvider.of<HomeCubit>(context);
    final size = MediaQuery.sizeOf(context);
    return Column(
      children: [
        SizedBox(
          height: size.height * 0.15,
          child: BlocConsumer<HomeCubit, HomeState>(
            bloc: homeCubit,
            listenWhen: (previous, current) => current is! StoryError,
            listener: (context, state) {
              if (state is StoryError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: AppColors.red,
                  ),
                );
              }
            },
            buildWhen: (previous, current) =>
                current is StoryLoading ||
                current is StoryLoaded ||
                current is StoryError,
            builder: (context, state) {
              if (state is StoryLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is StoryLoaded) {
                final stories = state.stories;
                return ListView.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: stories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const StoryItem();
                    }
                    return StoryItem(story: stories[index - 1]);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class StoryItem extends StatelessWidget {
  final StoryModel? story;
  const StoryItem({super.key, this.story});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            if (story == null) {}
          },
          child: Container(
            decoration: BoxDecoration(
              color: story == null ? AppColors.indicatorColor : null,
              border: Border.all(
                color: story == null
                    ? AppColors.indicatorColor
                    : AppColors.primaryColor,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: story == null ? AppColors.indicatorColor : null,
              child: story == null
                  ? const Icon(Icons.add, size: 30, color: AppColors.white)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CachedNetworkImage(
                        imageUrl: story!.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          story == null ? "Share Story" : story!.authorName.split(' ').first,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
