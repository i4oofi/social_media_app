import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      child: const Scaffold(
        backgroundColor: AppColors.white,
        body: DiscoverBody(),
      ),
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
    final discoverCubit = context.read<DiscoverCubit>();
    final currentUserId =
        discoverCubit.discoverServices.supabase.auth.currentUser?.id;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Discover People",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Find interesting people to follow and build your network",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.darkGrey),
                ),
              ],
            ),
          ),

          // Search Bar Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.black),
                decoration: InputDecoration(
                  hintText: "Search by name or title...",
                  hintStyle: TextStyle(color: AppColors.darkGrey),
                  prefixIcon: const Icon(Icons.search, color: AppColors.black),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.black),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
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
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => discoverCubit.fetchAllUsers(),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is DiscoverSuccess) {
                  // Filter local list based on query
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search_rounded,
                            size: 64,
                            color: AppColors.darkGrey.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? "No matching users found"
                                : "No people to discover right now",
                            style: TextStyle(
                              color: AppColors.darkGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24, top: 4),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final isFollowing =
                          user.followers?.contains(currentUserId ?? '') ??
                          false;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.dividerColor.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
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
                                    // Refresh list when returning in case profile changes occurred
                                    discoverCubit.fetchAllUsers();
                                  });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // User Avatar
                                  UserAvatar(
                                    imageUrl: user.imageUrl,
                                    name: user.name,
                                    radius: 26,
                                  ),
                                  const SizedBox(width: 12),

                                  // User Info
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
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        if (user.title != null &&
                                            user.title!.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            user.title!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.people_alt_outlined,
                                              size: 14,
                                              color: AppColors.darkGrey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "${user.followersCount} followers",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.darkGrey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Follow Button
                                  MainButton(
                                    onPressed: () {
                                      discoverCubit.toggleFollowUser(user.id);
                                    },
                                    text: isFollowing ? 'Following' : 'Follow',
                                    transparent: isFollowing,
                                    width: 110,
                                    height: 32,
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
