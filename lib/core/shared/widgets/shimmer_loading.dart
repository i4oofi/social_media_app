import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media_app/core/theme/app_colors.dart';

// ─── Base Shimmer Box ───────────────────────────────────────────────────────

/// A base shimmer-animated container.
/// Use this to build any shaped placeholder element.
class ShimmerBox extends StatelessWidget {
  ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.isCircle = false,
  });

  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isCircle
              ? BorderRadius.circular(width / 2)
              : BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// ─── Post Shimmer ─────────────────────────────────────────────────────────────

/// Skeleton that mimics the layout of `PostCard`.
class PostShimmer extends StatelessWidget {
  const PostShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author row
            Row(
              children: [
                ShimmerBox(width: 40.w, height: 40.h, isCircle: true),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120.w, height: 13.h, borderRadius: 6),
                    SizedBox(height: 6.h),
                    ShimmerBox(width: 72.w, height: 11.h, borderRadius: 6),
                  ],
                ),
              ],
            ),
            SizedBox(height: 14.h),
            // Image placeholder
            ShimmerBox(width: double.infinity, height: 180.h, borderRadius: 10),
            SizedBox(height: 12.h),
            // Text lines
            ShimmerBox(width: double.infinity, height: 13.h, borderRadius: 6),
            SizedBox(height: 6.h),
            ShimmerBox(width: 200.w, height: 13.h, borderRadius: 6),
            SizedBox(height: 14.h),
            // Like / Comment row
            Row(
              children: [
                ShimmerBox(width: 28.w, height: 28.h, isCircle: true),
                SizedBox(width: 6.w),
                ShimmerBox(width: 24.w, height: 11.h, borderRadius: 6),
                SizedBox(width: 16.w),
                ShimmerBox(width: 28.w, height: 28.h, isCircle: true),
                SizedBox(width: 6.w),
                ShimmerBox(width: 24.w, height: 11.h, borderRadius: 6),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Story Shimmer ────────────────────────────────────────────────────────────

/// Skeleton that mimics a single story circle item.
class StoryShimmer extends StatelessWidget {
  const StoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShimmerBox(width: 68.w, height: 68.h, isCircle: true),
        SizedBox(height: 6.h),
        ShimmerBox(width: 52.w, height: 10.h, borderRadius: 6),
      ],
    );
  }
}

// ─── Discover User Shimmer ────────────────────────────────────────────────────

/// Skeleton that mimics a user row card in DiscoverScreen / Inbox.
class DiscoverUserShimmer extends StatelessWidget {
  const DiscoverUserShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          ShimmerBox(width: 52.w, height: 52.h, isCircle: true),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 120.w, height: 13.h, borderRadius: 6),
                SizedBox(height: 6.h),
                ShimmerBox(width: 80.w, height: 11.h, borderRadius: 6),
                SizedBox(height: 6.h),
                ShimmerBox(width: 60.w, height: 10.h, borderRadius: 6),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          ShimmerBox(width: 90.w, height: 32.h, borderRadius: 20),
        ],
      ),
    );
  }
}

// ─── Profile Header Shimmer ───────────────────────────────────────────────────

/// Skeleton for the full profile screen header (cover + avatar + name + stats).
class ProfileHeaderShimmer extends StatelessWidget {
  const ProfileHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image
              ShimmerBox(
                width: double.infinity,
                height: 200.h,
                borderRadius: 0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    // Avatar + follow button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ShimmerBox(width: 90.w, height: 90.h, isCircle: true),
                        ShimmerBox(
                          width: 110.w,
                          height: 36.h,
                          borderRadius: 20,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // Name
                    ShimmerBox(width: 160.w, height: 18.h, borderRadius: 8),
                    SizedBox(height: 8.h),
                    // Bio
                    ShimmerBox(width: 220.w, height: 13.h, borderRadius: 6),
                    SizedBox(height: 6.h),
                    ShimmerBox(width: 180.w, height: 13.h, borderRadius: 6),
                    SizedBox(height: 20.h),
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _statShimmer(),
                        _statShimmer(),
                        _statShimmer(),
                      ],
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statShimmer() {
    return Column(
      children: [
        ShimmerBox(width: 50.w, height: 20.h, borderRadius: 6),
        SizedBox(height: 4.h),
        ShimmerBox(width: 60.w, height: 11.h, borderRadius: 6),
      ],
    );
  }
}

// ─── Inbox Chat Shimmer ───────────────────────────────────────────────────────

/// Skeleton that mimics a chat row in the InboxScreen.
class InboxChatShimmer extends StatelessWidget {
  const InboxChatShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          ShimmerBox(width: 56.w, height: 56.h, isCircle: true),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 130.w, height: 14.h, borderRadius: 6),
                    ShimmerBox(width: 48.w, height: 11.h, borderRadius: 6),
                  ],
                ),
                SizedBox(height: 8.h),
                ShimmerBox(width: 200.w, height: 12.h, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
