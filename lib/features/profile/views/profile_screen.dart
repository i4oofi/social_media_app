import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/profile/cubit/profile_cubit.dart';
import 'package:social_media_app/features/profile/widgets/profile_body.dart';
import 'package:social_media_app/features/profile/widgets/profile_header.dart';
import 'package:social_media_app/features/profile/widgets/profile_stats.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ProfileCubit();
        cubit.fetchUserProfile();
        cubit.fetchUserPosts();
        return cubit;
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (previous, current) =>
            current is ProfileLoading ||
            current is ProfileSuccess ||
            current is ProfileFailure,
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileFailure) {
            return Center(child: Text(state.message));
          }
          if (state is ProfileSuccess) {
            final userData = state.user;
            return SafeArea(
              child: DefaultTabController(
                length: 2,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            ProfileHeader(userData: userData),
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
                      ProfileDetails(user: userData),
                      ProfilePosts(user: userData),
                    ],
                  ),
                ),
              ),
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
