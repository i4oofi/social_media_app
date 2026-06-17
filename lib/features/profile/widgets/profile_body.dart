import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/core/shared/widgets/animated_empty_state.dart';
import 'package:social_media_app/core/shared/widgets/post_card.dart';
import 'package:social_media_app/core/shared/widgets/shimmer_loading.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/features/profile/cubit/profile_cubit/profile_cubit.dart';

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key, required this.userData});
  final UserData userData;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Posts'),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ProfileDetails(user: userData),
                ProfilePosts(user: userData),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileDetails extends StatelessWidget {
  const ProfileDetails({super.key, required this.user, this.isPrivate = true});
  final UserData user;
  final bool isPrivate;

  @override
  Widget build(BuildContext context) {
    final joinDate = DateFormat('MMMM yyyy').format(DateTime.now());

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── About Section ──
          _DetailsSectionCard(
            icon: Icons.person_outline_rounded,
            title: 'About',
            children: [
              _DetailRow(
                icon: Icons.badge_outlined,
                label: 'Display Name',
                value: user.name,
              ),
              _DetailRow(
                icon: Icons.short_text_rounded,
                label: 'Bio',
                value: user.title ?? 'No bio yet',
                isSubtle: user.title == null,
              ),
              _DetailRow(
                icon: Icons.cake_outlined,
                label: 'Date of Birth',
                value: user.dob ?? 'Unknown',
                isSubtle: user.dob == null || user.dob!.isEmpty,
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // ── Contact Info (private only) ──
          if (isPrivate) ...[
            _DetailsSectionCard(
              icon: Icons.mail_outline_rounded,
              title: 'Contact Info',
              children: [
                _DetailRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user.email,
                ),
              ],
            ),
            SizedBox(height: 14.h),
          ],

          // ── Account Info ──
          _DetailsSectionCard(
            icon: Icons.info_outline_rounded,
            title: 'Account Info',
            children: [
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Joined',
                value: joinDate,
              ),
              _DetailRow(
                icon: Icons.article_outlined,
                label: 'Total Posts',
                value: '${user.postsCount ?? 0}',
              ),
              _DetailRow(
                icon: Icons.people_outline_rounded,
                label: 'Followers',
                value: '${user.followersCount ?? 0}',
              ),
              _DetailRow(
                icon: Icons.person_add_alt_outlined,
                label: 'Following',
                value: '${user.followingCount ?? 0}',
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // ── Activity Summary ──
          _DetailsSectionCard(
            icon: Icons.insights_rounded,
            title: 'Activity',
            children: [
              _ActivityChip(
                icon: Icons.photo_library_outlined,
                label: '${user.postsCount ?? 0} posts shared',
                color:
                    Theme.of(context).textTheme.bodyLarge?.color ??
                    AppColors.black,
              ),
              SizedBox(height: 8.h),
              _ActivityChip(
                icon: Icons.favorite_border_rounded,
                label: '${user.followersCount ?? 0} people follow this account',
                color:
                    Theme.of(context).textTheme.bodyLarge?.color ??
                    AppColors.black,
              ),
              SizedBox(height: 8.h),
              _ActivityChip(
                icon: Icons.visibility_outlined,
                label: '${user.followingCount ?? 0} accounts being followed',
                color:
                    Theme.of(context).textTheme.bodyLarge?.color ??
                    AppColors.black,
              ),
            ],
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

/// A styled section card with a header icon + title and a list of children.
class _DetailsSectionCard extends StatelessWidget {
  const _DetailsSectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header ──
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 14.w, 14.h),
            child: Row(
              children: [
                Icon(icon, size: 20.h, color: theme.iconTheme.color),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Divider(
              height: 20.h,
              thickness: 0.5,
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
          ),
          // ── Section Content ──
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 0.w, 0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single detail row with an icon, label, and value.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isSubtle = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isSubtle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.h, color: theme.hintColor),
          SizedBox(width: 12.w),
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isSubtle
                    ? theme.hintColor
                    : theme.textTheme.bodyLarge?.color,
                fontStyle: isSubtle ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact activity chip with an icon, text, and accent color.
class _ActivityChip extends StatelessWidget {
  const _ActivityChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.h, color: color),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePosts extends StatelessWidget {
  const ProfilePosts({super.key, required this.user});
  final UserData user;
  @override
  Widget build(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();
    return BlocBuilder<ProfileCubit, ProfileState>(
      bloc: profileCubit,
      buildWhen: (previous, current) =>
          current is ProfilePostsLoading ||
          current is ProfilePostsSuccess ||
          current is ProfilePostsFailure,
      builder: (context, state) {
        if (state is ProfilePostsLoading) {
          return ListView.builder(
            itemCount: 4,
            itemBuilder: (_, __) => const PostShimmer(),
          );
        }
        if (state is ProfilePostsFailure) {
          return Center(child: Text(state.message));
        }
        if (state is ProfilePostsSuccess) {
          final posts = state.posts;
          final isLoadingMore = state.isLoadingMore;

          if (posts.isEmpty && !isLoadingMore) {
            return const AnimatedEmptyState(
              icon: Icons.grid_on_rounded,
              title: 'No Posts Yet',
              subtitle: 'This account hasn\'t posted anything yet.',
              // imagePath: 'assets/images/empty_profile_posts.gif', // uncomment when GIF is added
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              itemCount: posts.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == posts.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation(
                          AppColors.primaryColor,
                        ),
                      ),
                    ),
                  );
                }
                final post = posts[index];
                return Column(children: [PostCard(post: post)]);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
