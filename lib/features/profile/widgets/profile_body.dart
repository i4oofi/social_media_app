import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/core/shared/widgets/post_card.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            ],
          ),
          const SizedBox(height: 14),

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
            const SizedBox(height: 14),
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
          const SizedBox(height: 14),

          // ── Activity Summary ──
          _DetailsSectionCard(
            icon: Icons.insights_rounded,
            title: 'Activity',
            children: [
              _ActivityChip(
                icon: Icons.photo_library_outlined,
                label: '${user.postsCount ?? 0} posts shared',
                color: AppColors.black,
              ),
              const SizedBox(height: 8),
              _ActivityChip(
                icon: Icons.favorite_border_rounded,
                label: '${user.followersCount ?? 0} people follow this account',
                color: AppColors.black,
              ),
              const SizedBox(height: 8),
              _ActivityChip(
                icon: Icons.visibility_outlined,
                label: '${user.followingCount ?? 0} accounts being followed',
                color: AppColors.black,
              ),
            ],
          ),
          const SizedBox(height: 24),
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.black),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 20, thickness: 0.5),
          ),
          // ── Section Content ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.darkGrey),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isSubtle ? AppColors.grey : AppColors.black,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
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
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProfilePostsFailure) {
          return Center(child: Text(state.message));
        }
        if (state is ProfilePostsSuccess) {
          final posts = state.posts;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
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

