import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_media_app/core/cubit/posts_cubit/posts_cubit.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/reels/cubit/reels_cubit.dart';
import 'package:social_media_app/features/home/widgets/comments_sheet.dart';

class ReelInteractionSidebar extends StatefulWidget {
  final PostModel reel;
  const ReelInteractionSidebar({super.key, required this.reel});

  @override
  State<ReelInteractionSidebar> createState() => _ReelInteractionSidebarState();
}

class _ReelInteractionSidebarState extends State<ReelInteractionSidebar>
    with TickerProviderStateMixin {
  // Like animation
  late final AnimationController _likeController;
  late final Animation<double> _likeScale;

  // Floating heart
  late final AnimationController _heartFloatController;
  late final Animation<double> _heartOpacity;
  late final Animation<double> _heartOffset;
  late final Animation<double> _heartScale;
  bool _showFloatingHeart = false;

  // Save animation
  late final AnimationController _saveController;
  late final Animation<double> _saveScale;

  // Share animation
  late final AnimationController _shareController;
  late final Animation<double> _shareScale;

  @override
  void initState() {
    super.initState();

    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _likeScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.5,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.5,
          end: 0.85,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.85,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 35,
      ),
    ]).animate(_likeController);

    _heartFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _heartOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 35,
      ),
    ]).animate(_heartFloatController);
    _heartOffset = Tween<double>(begin: 0.0, end: -55.0).animate(
      CurvedAnimation(parent: _heartFloatController, curve: Curves.easeOut),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.4,
          end: 1.5,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 60),
    ]).animate(_heartFloatController);

    _saveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _saveScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.4,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.4,
          end: 0.9,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.9,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 35,
      ),
    ]).animate(_saveController);

    _shareController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shareScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.35,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.35,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_shareController);
  }

  @override
  void dispose() {
    _likeController.dispose();
    _heartFloatController.dispose();
    _saveController.dispose();
    _shareController.dispose();
    super.dispose();
  }

  void _triggerLike() {
    _likeController.forward(from: 0);
    if (!widget.reel.isLiked) {
      setState(() => _showFloatingHeart = true);
      _heartFloatController.forward(from: 0).then((_) {
        if (mounted) setState(() => _showFloatingHeart = false);
      });
    }
    HapticFeedback.lightImpact();
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final reel = widget.reel;
    final size = MediaQuery.of(context).size;

    return BlocBuilder<ReelsCubit, dynamic>(
      buildWhen: (prev, curr) => true,
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // ── Like ─────────────────────────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                _SidebarButton(
                  onTap: () {
                    _triggerLike();
                    context.read<ReelsCubit>().toggleLike(reel.id);
                  },
                  icon: AnimatedBuilder(
                    animation: _likeScale,
                    builder: (context, child) => Transform.scale(
                      scale: _likeScale.value,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          reel.isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          key: ValueKey(reel.isLiked),
                          color: reel.isLiked
                              ? AppColors.primaryColor
                              : Colors.white,
                          size: 30.sp,
                        ),
                      ),
                    ),
                  ),
                  label: _formatCount(reel.likes?.length ?? 0),
                  labelColor: reel.isLiked
                      ? AppColors.primaryColor
                      : Colors.white,
                ),
                // Floating heart
                if (_showFloatingHeart)
                  Positioned(
                    top: -10,
                    child: AnimatedBuilder(
                      animation: _heartFloatController,
                      builder: (context, child) => Opacity(
                        opacity: _heartOpacity.value,
                        child: Transform.translate(
                          offset: Offset(0, _heartOffset.value),
                          child: Transform.scale(
                            scale: _heartScale.value,
                            child: Icon(
                              Icons.favorite_rounded,
                              color: AppColors.primaryColor,
                              size: 22.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 22.h),

            // ── Comment ───────────────────────────────────────────────
            _SidebarButton(
              onTap: () {
                HapticFeedback.selectionClick();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  backgroundColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.r),
                    ),
                  ),
                  builder: (sheetContext) => SizedBox(
                    height: size.height * 0.8,
                    width: size.width,
                    child: SafeArea(
                      child: BlocProvider.value(
                        value: context.read<PostsCubit>(),
                        child: CommentsSheet(post: reel),
                      ),
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.chat_bubble_outline_rounded,
                color: Colors.white,
                size: 28.sp,
              ),
              label: _formatCount(reel.commentCount ?? 0),
            ),

            SizedBox(height: 22.h),

            // ── Save ──────────────────────────────────────────────────
            BlocBuilder<PostsCubit, PostsState>(
              buildWhen: (prev, curr) => curr is SavedPostsLoaded,
              builder: (context, postsState) {
                final postsCubit = context.read<PostsCubit>();
                final isSaved = postsCubit.savedPostIds.contains(reel.id);
                return _SidebarButton(
                  onTap: () {
                    _saveController.forward(from: 0);
                    HapticFeedback.selectionClick();
                    postsCubit.toggleSavePost(reel.id);
                  },
                  icon: AnimatedBuilder(
                    animation: _saveScale,
                    builder: (context, child) => Transform.scale(
                      scale: _saveScale.value,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          key: ValueKey(isSaved),
                          color: isSaved
                              ? AppColors.primaryColor
                              : Colors.white,
                          size: 28.sp,
                        ),
                      ),
                    ),
                  ),
                  label: isSaved ? 'Saved' : 'Save',
                  labelColor: isSaved ? AppColors.primaryColor : Colors.white,
                );
              },
            ),

            SizedBox(height: 22.h),

            // ── Share ─────────────────────────────────────────────────
            AnimatedBuilder(
              animation: _shareScale,
              builder: (context, child) =>
                  Transform.scale(scale: _shareScale.value, child: child),
              child: _SidebarButton(
                onTap: () async {
                  _shareController.forward(from: 0);
                  HapticFeedback.lightImpact();
                  final author = reel.authorName ?? 'Someone';
                  final text = reel.text.trim().isNotEmpty
                      ? '"${reel.text.trim()}"'
                      : 'a reel';
                  await SharePlus.instance.share(
                    ShareParams(
                      text: '🎬 Check out this reel by $author — $text',
                    ),
                  );
                },
                icon: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 28.sp,
                ),
                label: 'Share',
              ),
            ),

            SizedBox(height: 36.h),
          ],
        );
      },
    );
  }
}

/// A single sidebar action button (icon + label) with a frosted glass pill bg.
class _SidebarButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget icon;
  final String label;
  final Color labelColor;

  const _SidebarButton({
    required this.onTap,
    required this.icon,
    required this.label,
    this.labelColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Center(child: icon),
          ),
          SizedBox(height: 5.h),
          Text(
            label,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
