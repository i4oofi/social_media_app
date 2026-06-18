import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';

class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({super.key, required this.userData});
  final UserData userData;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : AppColors.primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : AppColors.primaryColor.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : AppColors.primaryColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      child: Row(
        children: [
          Expanded(
            child: _AnimatedStatItem(
              number: userData.postsCount ?? 0,
              label: 'Posts',
              icon: Icons.grid_on_rounded,
            ),
          ),
          _Divider(),
          Expanded(
            child: _AnimatedStatItem(
              number: userData.followersCount ?? 0,
              label: 'Followers',
              icon: Icons.people_rounded,
            ),
          ),
          _Divider(),
          Expanded(
            child: _AnimatedStatItem(
              number: userData.followingCount ?? 0,
              label: 'Following',
              icon: Icons.person_add_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: VerticalDivider(
        color: AppColors.grey.withValues(alpha: 0.6),
        thickness: 0.8,
        width: 1,
      ),
    );
  }
}

/// Stat item with a count-up animation when first displayed.
class _AnimatedStatItem extends StatefulWidget {
  const _AnimatedStatItem({
    required this.number,
    required this.label,
    required this.icon,
  });

  final num number;
  final String label;
  final IconData icon;

  @override
  State<_AnimatedStatItem> createState() => _AnimatedStatItemState();
}

class _AnimatedStatItemState extends State<_AnimatedStatItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _countAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _countAnim = Tween<double>(
      begin: 0,
      end: widget.number.toDouble(),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.7, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    // Delay slightly so it runs after the header entrance animation settles
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(double value) {
    final int v = value.round();
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              size: 16.sp,
              color: AppColors.primaryColor.withValues(alpha: 0.7),
            ),
            SizedBox(height: 4.h),
            Text(
              _format(_countAnim.value),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18.sp,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              widget.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w500,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Keep old ProfileStatItem for backward compat if anything imports it
class ProfileStatItem extends StatelessWidget {
  const ProfileStatItem({super.key, required this.number, required this.label});
  final num number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number.toString(),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: AppColors.darkGrey),
        ),
      ],
    );
  }
}
