import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';
import 'package:social_media_app/features/home/models/story_model.dart';
import 'package:social_media_app/features/home/views/story_view_screen.dart';

class StoriesSection extends StatefulWidget {
  const StoriesSection({super.key});

  @override
  State<StoriesSection> createState() => _StoriesSectionState();
}

class _StoriesSectionState extends State<StoriesSection> {
  List<StoryModel> _stories = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final homeCubit = BlocProvider.of<HomeCubit>(context);
    final size = MediaQuery.sizeOf(context);

    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is StoryLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is StoryLoaded) {
          setState(() {
            _stories = state.stories;
            _isLoading = false;
          });
        } else if (state is StoryError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: size.height * 0.14,
            child: _isLoading && _stories.isEmpty
                ? const Center(child: CircularProgressIndicator.adaptive())
                : ListView.separated(
                    separatorBuilder: (context, index) => const SizedBox(width: 14),
                    scrollDirection: Axis.horizontal,
                    itemCount: _stories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return StoryItem(
                          onTap: () => homeCubit.shareStory(),
                        );
                      }
                      final storyIndex = index - 1;
                      return StoryItem(
                        story: _stories[storyIndex],
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => StoryViewScreen(
                                stories: _stories,
                                initialIndex: storyIndex,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class StoryItem extends StatelessWidget {
  final StoryModel? story;
  final VoidCallback onTap;

  const StoryItem({
    super.key,
    this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: story == null
              ? Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.dividerColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.grey.withValues(alpha: 0.08),
                        child: const Icon(
                          Icons.person,
                          size: 32,
                          color: AppColors.dividerColor,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const CircleAvatar(
                          radius: 9,
                          backgroundColor: AppColors.primaryColor,
                          child: Icon(
                            Icons.add,
                            size: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xffFF512F),
                        Color(0xffDD2476),
                        Color(0xff8E54E9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 29,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: story!.imageUrl,
                          fit: BoxFit.cover,
                          width: 58,
                          height: 58,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.withValues(alpha: 0.1),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.withValues(alpha: 0.2),
                            child: const Icon(
                              Icons.broken_image,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 74,
          child: Text(
            story == null ? "Your Story" : story!.authorName.split(' ').first,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
          ),
        ),
      ],
    );
  }
}
