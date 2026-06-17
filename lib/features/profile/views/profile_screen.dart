import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      buildWhen: (previous, current) =>
          current is ProfileLoading ||
          current is ProfileSuccess ||
          current is ProfileFailure,
      builder: (context, state) {
        if (state is ProfileLoading ||
            state is ProfileInitial ||
            state is ProfilePostsLoading) {
          return const Scaffold(body: SafeArea(child: ProfileHeaderShimmer()));
        }

        // ── Error ────────────────────────────────────────────────────────
        if (state is ProfileFailure) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48.h, color: Colors.red),
                  SizedBox(height: 12.h),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
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
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 200) {
                        cubit.loadMoreUserPosts(userId: userId);
                      }
                      return false;
                    },
                    child: NestedScrollView(
                      // Must be AlwaysScrollable so RefreshIndicator
                      // can be triggered even when content fills the screen.
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                ProfileHeader(
                                  userData: userData,
                                  isPrivate: isPrivate,
                                ),
                                SizedBox(height: 24.h),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.w),
                                  child: Column(
                                    children: [
                                      ProfileStatsCard(userData: userData),
                                      SizedBox(height: 16.h),
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
