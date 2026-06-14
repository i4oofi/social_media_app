import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media_app/core/theme/app_colors.dart';

// ─── Base Shimmer Box ───────────────────────────────────────────────────────

/// A base shimmer-animated container.
/// Use this to build any shaped placeholder element.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
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
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author row
            Row(
              children: [
                ShimmerBox(width: 40, height: 40, isCircle: true),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120, height: 13, borderRadius: 6),
                    const SizedBox(height: 6),
                    ShimmerBox(width: 72, height: 11, borderRadius: 6),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Image placeholder
            ShimmerBox(width: double.infinity, height: 180, borderRadius: 10),
            const SizedBox(height: 12),
            // Text lines
            ShimmerBox(width: double.infinity, height: 13, borderRadius: 6),
            const SizedBox(height: 6),
            ShimmerBox(width: 200, height: 13, borderRadius: 6),
            const SizedBox(height: 14),
            // Like / Comment row
            Row(
              children: [
                ShimmerBox(width: 28, height: 28, isCircle: true),
                const SizedBox(width: 6),
                ShimmerBox(width: 24, height: 11, borderRadius: 6),
                const SizedBox(width: 16),
                ShimmerBox(width: 28, height: 28, isCircle: true),
                const SizedBox(width: 6),
                ShimmerBox(width: 24, height: 11, borderRadius: 6),
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
        ShimmerBox(width: 68, height: 68, isCircle: true),
        const SizedBox(height: 6),
        ShimmerBox(width: 52, height: 10, borderRadius: 6),
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          ShimmerBox(width: 52, height: 52, isCircle: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 120, height: 13, borderRadius: 6),
                const SizedBox(height: 6),
                ShimmerBox(width: 80, height: 11, borderRadius: 6),
                const SizedBox(height: 6),
                ShimmerBox(width: 60, height: 10, borderRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ShimmerBox(width: 90, height: 32, borderRadius: 20),
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
              ShimmerBox(width: double.infinity, height: 200, borderRadius: 0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Avatar + follow button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ShimmerBox(width: 90, height: 90, isCircle: true),
                        ShimmerBox(width: 110, height: 36, borderRadius: 20),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Name
                    ShimmerBox(width: 160, height: 18, borderRadius: 8),
                    const SizedBox(height: 8),
                    // Bio
                    ShimmerBox(width: 220, height: 13, borderRadius: 6),
                    const SizedBox(height: 6),
                    ShimmerBox(width: 180, height: 13, borderRadius: 6),
                    const SizedBox(height: 20),
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _statShimmer(),
                        _statShimmer(),
                        _statShimmer(),
                      ],
                    ),
                    const SizedBox(height: 20),
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
        ShimmerBox(width: 50, height: 20, borderRadius: 6),
        const SizedBox(height: 4),
        ShimmerBox(width: 60, height: 11, borderRadius: 6),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          ShimmerBox(width: 56, height: 56, isCircle: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 130, height: 14, borderRadius: 6),
                    ShimmerBox(width: 48, height: 11, borderRadius: 6),
                  ],
                ),
                const SizedBox(height: 8),
                ShimmerBox(width: 200, height: 12, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
