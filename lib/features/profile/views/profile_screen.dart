import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/shared/widgets/shimmer_loading.dart';
import 'package:social_media_app/features/profile/cubit/profile_cubit/profile_cubit.dart';
import 'package:social_media_app/features/profile/widgets/profile_body.dart';
import 'package:social_media_app/features/profile/widgets/profile_header.dart';
import 'package:social_media_app/features/profile/widgets/profile_stats.dart';
import 'package:social_media_app/features/settings/views/setting_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ProfileCubit();
        // Initial load — NOT silent → shows full shimmer.
        cubit.fetchUserProfile(userId: userId);
        cubit.fetchUserPosts(userId: userId);
        return cubit;
      },
      child: _ProfileScreenContent(userId: userId),
    );
  }
}

class _ProfileScreenContent extends StatelessWidget {
  final String? userId;
  const _ProfileScreenContent({this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      // Only rebuild the root when profile data (or loading) changes.
      // ProfileRefreshing keeps the old ProfileSuccess UI alive.
      buildWhen: (previous, current) =>
          current is ProfileLoading ||
          current is ProfileSuccess ||
          current is ProfileFailure,
      builder: (context, state) {
        // ── Full-page shimmer on first load ──────────────────────────────
        if (state is ProfileLoading) {
          return const Scaffold(body: SafeArea(child: ProfileHeaderShimmer()));
        }

        // ── Error ────────────────────────────────────────────────────────
        if (state is ProfileFailure) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        }

        // ── Success ──────────────────────────────────────────────────────
        if (state is ProfileSuccess) {
          final userData = state.user;
          final cubit = context.read<ProfileCubit>();
          final currentUserId =
              cubit.coreAuthServices.supabase.auth.currentUser?.id;
          final isPrivate = currentUserId == userData.id;

          return Scaffold(
            drawer: const SettingsDrawer(),
            body: SafeArea(
              child: DefaultTabController(
                length: 2,
                child: RefreshIndicator(
                  // Silent refresh — does NOT emit ProfileLoading
                  onRefresh: () => cubit.refreshProfile(userId: userId),
                  child: NestedScrollView(
                    // Must be AlwaysScrollable so RefreshIndicator
                    // can be triggered even when content fills the screen.
                    physics: const AlwaysScrollableScrollPhysics(),
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              ProfileHeader(
                                userData: userData,
                                isPrivate: isPrivate,
                              ),
                              const SizedBox(height: 24),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  children: [
                                    ProfileStatsCard(userData: userData),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _TabBarDelegate(
                            TabBar(
                              dividerColor: Colors.transparent,
                              tabs: const [
                                Tab(text: 'Details'),
                                Tab(text: 'Posts'),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      children: [
                        ProfileDetails(user: userData, isPrivate: isPrivate),
                        ProfilePosts(user: userData),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
