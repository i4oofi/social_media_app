import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/shared/widgets/animated_empty_state.dart';
import 'package:social_media_app/core/shared/widgets/shimmer_loading.dart';
import 'package:social_media_app/core/shared/widgets/user_avatar.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/auth/widgets/main_button.dart';
import 'package:social_media_app/features/discover/cubit/discover_cubit.dart';
import 'package:social_media_app/features/profile/views/profile_screen.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiscoverCubit()..fetchAllUsers(),
      child: const Scaffold(body: DiscoverBody()),
    );
  }
}

class DiscoverBody extends StatefulWidget {
  const DiscoverBody({super.key});

  @override
  State<DiscoverBody> createState() => _DiscoverBodyState();
}

class _DiscoverBodyState extends State<DiscoverBody> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final discoverCubit = context.read<DiscoverCubit>();
    final currentUserId =
        discoverCubit.discoverServices.supabase.auth.currentUser?.id;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Discover People",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Find interesting people to follow and build your network",
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Search Bar Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Container(
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search by name or title...",
                  hintStyle: TextStyle(color: theme.hintColor),
                  prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: theme.iconTheme.color),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
          ),

          // Content Section
          Expanded(
            child: BlocBuilder<DiscoverCubit, DiscoverState>(
              buildWhen: (previous, current) =>
                  current is DiscoverLoading ||
                  current is DiscoverFailure ||
                  current is DiscoverSuccess,
              builder: (context, state) {
                if (state is DiscoverLoading) {
                  return ListView.builder(
                    itemCount: 7,
                    itemBuilder: (_, __) => const DiscoverUserShimmer(),
                  );
                } else if (state is DiscoverFailure) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.red,
                            size: 48.h,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            state.errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.red),
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () => discoverCubit.fetchAllUsers(),
                            child: Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is DiscoverSuccess) {
                  final filteredUsers = state.users.where((user) {
                    final nameMatch = user.name.toLowerCase().contains(
                      _searchQuery,
                    );
                    final titleMatch = (user.title ?? "")
                        .toLowerCase()
                        .contains(_searchQuery);
                    return nameMatch || titleMatch;
                  }).toList();

                  if (filteredUsers.isEmpty) {
                    return AnimatedEmptyState(
                      icon: Icons.person_search_rounded,
                      title: _searchQuery.isNotEmpty
                          ? "No matching users found"
                          : "No people to discover",
                      subtitle: _searchQuery.isNotEmpty
                          ? "Try searching for a different name or title"
                          : "Check back later for new accounts to follow",
                      // imagePath: 'assets/images/empty_discover.gif', // uncomment when GIF is added
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.only(bottom: 24.h, top: 4.h),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final isFollowing =
                          user.followers?.contains(currentUserId ?? '') ??
                          false;

                      return Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProfileScreen(userId: user.id),
                                    ),
                                  )
                                  .then((_) {
                                    discoverCubit.fetchAllUsers();
                                  });
                            },
                            child: Padding(
                              padding: EdgeInsets.all(12.0.w),
                              child: Row(
                                children: [
                                  UserAvatar(
                                    imageUrl: user.imageUrl,
                                    name: user.name,
                                    radius: 26.r,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          user.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.sp,
                                              ),
                                        ),
                                        if (user.title != null &&
                                            user.title!.isNotEmpty) ...[
                                          SizedBox(height: 2.h),
                                          Text(
                                            user.title!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(fontSize: 12.sp),
                                          ),
                                        ],
                                        SizedBox(height: 4.h),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.people_alt_outlined,
                                              size: 14.h,
                                              color: theme.hintColor,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              "${user.followersCount} followers",
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  MainButton(
                                    onPressed: () {
                                      discoverCubit.toggleFollowUser(user.id);
                                    },
                                    text: isFollowing ? 'Following' : 'Follow',
                                    transparent: isFollowing,
                                    width: 110.w,
                                    height: 32.h,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
