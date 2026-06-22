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

class PostShimmer extends StatelessWidget {
  const PostShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 6.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 8.w, 0),
              child: Row(
                children: [
                  ShimmerBox(width: 44.r, height: 44.r, isCircle: true),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 120.w, height: 14.h, borderRadius: 6),
                        SizedBox(height: 6.h),
                        ShimmerBox(width: 80.w, height: 11.h, borderRadius: 6),
                      ],
                    ),
                  ),
                  ShimmerBox(width: 22.sp, height: 22.sp, isCircle: true),
                  SizedBox(width: 8.w),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    width: double.infinity,
                    height: 14.5.sp,
                    borderRadius: 6,
                  ),
                  SizedBox(height: 6.h),
                  ShimmerBox(width: 200.w, height: 14.5.sp, borderRadius: 6),
                ],
              ),
            ),

            // Image placeholder
            ShimmerBox(width: double.infinity, height: 350.h, borderRadius: 0),

            // ── Divider ────────────────────────────────────────────────
            Divider(
              height: 1,
              thickness: 0.5,
              color: AppColors.dividerColor.withValues(alpha: 0.4),
            ),

            // ── Actions bar ────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              child: Row(
                children: [
                  // Like
                  SizedBox(
                    width: 40.w,
                    height: 40.h,
                    child: Center(
                      child: ShimmerBox(
                        width: 25.sp,
                        height: 25.sp,
                        isCircle: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  ShimmerBox(width: 20.w, height: 14.h, borderRadius: 4),

                  SizedBox(width: 12.w), // Space between actions
                  // Comment
                  SizedBox(
                    width: 40.w,
                    height: 40.h,
                    child: Center(
                      child: ShimmerBox(
                        width: 25.sp,
                        height: 25.sp,
                        isCircle: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  ShimmerBox(width: 20.w, height: 14.h, borderRadius: 4),

                  const Spacer(),

                  // Save
                  SizedBox(
                    width: 40.w,
                    height: 40.h,
                    child: Center(
                      child: ShimmerBox(
                        width: 25.sp,
                        height: 25.sp,
                        isCircle: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
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
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cover + Avatar ────────────────────────────────────────────
              SizedBox(
                height: size.height * 0.3 + 44,
                child: Stack(
                  children: [
                    // Cover photo
                    ShimmerBox(
                      width: size.width,
                      height: size.height * 0.3,
                      borderRadius: 0,
                    ),

                    // Avatar (centered)
                    Positioned(
                      bottom: 0,
                      left: size.width * 0.5 - 62,
                      right: size.width * 0.5 - 62,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: ShimmerBox(
                          width: 124.r,
                          height: 124.r,
                          isCircle: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Name / Username ───────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    Center(
                      child: ShimmerBox(
                        width: 180.w,
                        height: 24.sp,
                        borderRadius: 8,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Center(
                      child: ShimmerBox(
                        width: 120.w,
                        height: 13.sp,
                        borderRadius: 6,
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),

              // ── Action Buttons ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShimmerBox(
                      width: size.width * 0.5,
                      height: 48.h,
                      borderRadius: 24.r,
                    ),
                    SizedBox(width: 12.w),
                    ShimmerBox(width: 48.w, height: 48.h, borderRadius: 12.r),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // ── Profile Stats ─────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: ShimmerBox(
                  width: double.infinity,
                  height: 90.h,
                  borderRadius: 24.r,
                ),
              ),

              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
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
