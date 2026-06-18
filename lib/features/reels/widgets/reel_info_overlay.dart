import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/shared/widgets/user_avatar.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/features/profile/views/profile_screen.dart';
import 'package:social_media_app/features/reels/cubit/reels_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReelInfoOverlay extends StatelessWidget {
  final PostModel reel;

  const ReelInfoOverlay({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isOwner = currentUserId != null && currentUserId == reel.authorId;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.55),
            Colors.black.withValues(alpha: 0.85),
          ],
          stops: const [0.0, 0.55, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 70.w, 20.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(userId: reel.authorId),
                  ),
                ),
                child: Row(
                  children: [
                    // Avatar with ring
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                          width: 2,
                        ),
                      ),
                      child: UserAvatar(
                        imageUrl: reel.authorProfileImage,
                        name: reel.authorName ?? 'Unknown',
                        radius: 19.r,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      reel.authorName ?? 'Unknown',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                        letterSpacing: 0.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.7),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isOwner) ...[
                SizedBox(width: 12.w),
                _FollowButton(reel: reel),
              ],
            ],
          ),

          // Caption
          if (reel.text.trim().isNotEmpty) ...[
            SizedBox(height: 10.h),
            _ExpandableCaption(text: reel.text.trim()),
          ],

          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

/// Animated follow/following toggle button.
class _FollowButton extends StatefulWidget {
  final PostModel reel;
  const _FollowButton({required this.reel});

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFollowing = widget.reel.isFollowingAuthor ?? false;
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) async {
        await _controller.reverse();
        if (context.mounted) {
          context.read<ReelsCubit>().toggleFollow(widget.reel.authorId);
        }
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: isFollowing
                ? Colors.white.withValues(alpha: 0.15)
                : AppColors.primaryColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isFollowing ? Colors.white : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Text(
            isFollowing ? 'Following' : 'Follow',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

/// Caption that can be tapped to expand/collapse.
class _ExpandableCaption extends StatefulWidget {
  final String text;
  const _ExpandableCaption({required this.text});

  @override
  State<_ExpandableCaption> createState() => _ExpandableCaptionState();
}

class _ExpandableCaptionState extends State<_ExpandableCaption> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: Text(
          widget.text,
          maxLines: _expanded ? null : 2,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.92),
            fontSize: 13.5.sp,
            height: 1.5,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
