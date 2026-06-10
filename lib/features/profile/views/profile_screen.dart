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
        cubit.fetchUserProfile(userId: userId);
        cubit.fetchUserPosts(userId: userId);
        return cubit;
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (previous, current) =>
            current is ProfileLoading ||
            current is ProfileSuccess ||
            current is ProfileFailure,
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const ProfileHeaderShimmer();
          }
          if (state is ProfileFailure) {
            return Center(child: Text(state.message));
          }
          if (state is ProfileSuccess) {
            final userData = state.user;
            final currentUserId = BlocProvider.of<ProfileCubit>(context).coreAuthServices.supabase.auth.currentUser?.id;
            final isPrivate = currentUserId == userData.id;
            return Scaffold(
              drawer: const SettingsDrawer(),
              body: SafeArea(
                child: DefaultTabController(
                  length: 2,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      final cubit = BlocProvider.of<ProfileCubit>(context);
                      await Future.wait([
                        cubit.fetchUserProfile(userId: userId),
                        cubit.fetchUserPosts(userId: userId),
                      ]);
                    },
                    child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              ProfileHeader(userData: userData, isPrivate: isPrivate),
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Column(
                                  children: [
                                    ProfileStatsCard(userData: userData),
                                    SizedBox(height: 16),
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
              )
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);
  final TabBar tabBar;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return tabBar;
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
