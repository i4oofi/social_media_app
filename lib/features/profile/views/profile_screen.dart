import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/shared/widgets/shimmer_loading.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
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
        // ── Loading ────────────────────────────────────────────────────
        if (state is ProfileLoading ||
            state is ProfileInitial ||
            state is ProfilePostsLoading) {
          return const Scaffold(body: SafeArea(child: ProfileHeaderShimmer()));
        }

        // ── Error ──────────────────────────────────────────────────────
        if (state is ProfileFailure) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.error_outline_rounded,
                          size: 32.sp, color: Colors.red),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Failed to load profile',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.darkGrey),
                    ),
                    SizedBox(height: 24.h),
                    GestureDetector(
                      onTap: () => context
                          .read<ProfileCubit>()
                          .fetchUserProfile(userId: userId),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 28.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Try Again',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // ── Success ────────────────────────────────────────────────────
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
                  color: AppColors.primaryColor,
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
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                ProfileHeader(
                                  userData: userData,
                                  isPrivate: isPrivate,
                                ),
                                SizedBox(height: 20.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.w),
                                  child: ProfileStatsCard(userData: userData),
                                ),
                                SizedBox(height: 8.h),
                              ],
                            ),
                          ),
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _StyledTabBarDelegate(
                              TabBar(
                                dividerColor: Colors.transparent,
                                labelColor: AppColors.primaryColor,
                                unselectedLabelColor: AppColors.darkGrey,
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.sp,
                                  letterSpacing: 0.3,
                                ),
                                unselectedLabelStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.sp,
                                ),
                                indicator: UnderlineTabIndicator(
                                  borderRadius: BorderRadius.circular(4.r),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryColor,
                                    width: 3,
                                  ),
                                ),
                                tabs: [
                                  Tab(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.person_outline_rounded,
                                            size: 16.sp),
                                        SizedBox(width: 6.w),
                                        const Text('Details'),
                                      ],
                                    ),
                                  ),
                                  Tab(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.grid_on_rounded,
                                            size: 16.sp),
                                        SizedBox(width: 6.w),
                                        const Text('Posts'),
                                      ],
                                    ),
                                  ),
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

// ── Styled tab bar delegate ────────────────────────────────────────────────────

class _StyledTabBarDelegate extends SliverPersistentHeaderDelegate {
  _StyledTabBarDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final showShadow = shrinkOffset > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_StyledTabBarDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar;
}
