import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';
import 'package:social_media_app/features/home/models/story_model.dart';
import 'package:social_media_app/features/home/views/story_view_screen.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/core/shared/widgets/app_toast.dart';
import 'package:social_media_app/core/shared/widgets/shimmer_loading.dart';
import 'package:social_media_app/core/route/app_routes.dart';

class GroupedStory {
  final String authorId;
  final String authorName;
  final String? authorProfileImage;
  final List<StoryModel> stories;

  GroupedStory({
    required this.authorId,
    required this.authorName,
    this.authorProfileImage,
    required this.stories,
  });
}

class StoriesSection extends StatefulWidget {
  const StoriesSection({super.key});

  @override
  State<StoriesSection> createState() => _StoriesSectionState();
}

class _StoriesSectionState extends State<StoriesSection> {
  List<StoryModel> _stories = [];
  bool _isLoading = true;
  UserData? _currentUser;
  List<String> _viewedStoryIds = [];

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _loadViewedStoryIds();
  }

  Future<void> _fetchCurrentUser() async {
    final user = await CoreAuthServices().getCurrentUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _loadViewedStoryIds() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _viewedStoryIds = prefs.getStringList('viewed_story_ids') ?? [];
      });
    }
  }

  List<GroupedStory> _getGroupedStories() {
    final Map<String, List<StoryModel>> groups = {};
    for (final story in _stories) {
      groups.putIfAbsent(story.authorId, () => []).add(story);
    }

    final List<GroupedStory> groupedList = [];
    groups.forEach((authorId, userStories) {
      userStories.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final firstStory = userStories.first;
      groupedList.add(GroupedStory(
        authorId: authorId,
        authorName: firstStory.authorName,
        authorProfileImage: firstStory.authorProfileImage,
        stories: userStories,
      ));
    });

    return groupedList;
  }

  void _openStoryView(List<StoryModel> stories, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoryViewScreen(
          stories: stories,
          initialIndex: initialIndex,
        ),
      ),
    ).then((_) {
      _loadViewedStoryIds();
    });
  }

  void _openCreateStory(HomeCubit homeCubit) {
    Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.createStory,
      arguments: homeCubit,
    ).then((_) {
      homeCubit.fetchStories();
      _loadViewedStoryIds();
    });
  }

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
          AppToast.showToast(msg: state.error, backgroundColor: AppColors.red);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: size.height * 0.14,
            child: _isLoading && _stories.isEmpty
                ? ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemCount: 5,
                    itemBuilder: (_, __) => const StoryShimmer(),
                  )
                : Builder(
                    builder: (context) {
                      final groupedStories = _getGroupedStories();
                      
                      // Separate current user's story group
                      GroupedStory? myGroup;
                      final myUserId = _currentUser?.id;
                      if (myUserId != null) {
                        try {
                          myGroup = groupedStories.firstWhere((g) => g.authorId == myUserId);
                        } catch (_) {}
                      }

                      // general groups (excluding current user)
                      final otherGroups = myUserId != null
                          ? groupedStories.where((g) => g.authorId != myUserId).toList()
                          : groupedStories;

                      return ListView.separated(
                        separatorBuilder: (context, index) => const SizedBox(width: 14),
                        scrollDirection: Axis.horizontal,
                        itemCount: otherGroups.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return StoryItem(
                              isCurrentUser: true,
                              storyGroup: myGroup,
                              currentUser: _currentUser,
                              viewedStoryIds: _viewedStoryIds,
                              onTap: () {
                                if (myGroup != null && myGroup.stories.isNotEmpty) {
                                  // Find the first unviewed story
                                  int initialIndex = myGroup.stories.indexWhere(
                                    (s) => !_viewedStoryIds.contains(s.id),
                                  );
                                  if (initialIndex == -1) initialIndex = 0;
                                  _openStoryView(myGroup.stories, initialIndex);
                                } else {
                                  _openCreateStory(homeCubit);
                                }
                              },
                              onLongPress: () {
                                _openCreateStory(homeCubit);
                              },
                            );
                          }
                          
                          final groupIndex = index - 1;
                          final group = otherGroups[groupIndex];

                          return StoryItem(
                            isCurrentUser: false,
                            storyGroup: group,
                            viewedStoryIds: _viewedStoryIds,
                            onTap: () {
                              int initialIndex = group.stories.indexWhere(
                                (s) => !_viewedStoryIds.contains(s.id),
                              );
                              if (initialIndex == -1) initialIndex = 0;
                              _openStoryView(group.stories, initialIndex);
                            },
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
  final GroupedStory? storyGroup;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final UserData? currentUser;
  final bool isCurrentUser;
  final List<String> viewedStoryIds;

  const StoryItem({
    super.key,
    this.storyGroup,
    required this.onTap,
    this.onLongPress,
    this.currentUser,
    required this.isCurrentUser,
    required this.viewedStoryIds,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasStories = storyGroup != null && storyGroup!.stories.isNotEmpty;
    final bool allStoriesViewed = hasStories &&
        storyGroup!.stories.every((story) => viewedStoryIds.contains(story.id));

    final String? avatarUrl = isCurrentUser
        ? currentUser?.imageUrl
        : storyGroup?.authorProfileImage;

    final String displayName = isCurrentUser
        ? "Your Story"
        : (storyGroup?.authorName.split(' ').first ?? "");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasStories
                  ? (allStoriesViewed
                      ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                      : const LinearGradient(
                          colors: [
                            Color(0xffFF512F),
                            Color(0xffDD2476),
                            Color(0xff8E54E9),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ))
                  : null,
              border: !hasStories
                  ? Border.all(
                      color: AppColors.dividerColor.withValues(alpha: 0.3),
                      width: 1.5,
                    )
                  : null,
            ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 29,
                      backgroundColor: Colors.grey.withValues(alpha: 0.08),
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? CachedNetworkImageProvider(avatarUrl)
                          : null,
                      child: avatarUrl != null && avatarUrl.isNotEmpty
                          ? null
                          : const Icon(
                              Icons.person,
                              size: 29,
                              color: AppColors.dividerColor,
                            ),
                    ),
                    if (isCurrentUser && !hasStories)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 9,
                            backgroundColor: AppColors.primaryColor,
                            child: Icon(Icons.add, size: 13, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 74,
            child: Text(
              displayName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
            ),
          ),
      ],
    );
  }
}
