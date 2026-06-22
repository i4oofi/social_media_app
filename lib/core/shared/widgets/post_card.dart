import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/core/cubit/posts_cubit/posts_cubit.dart';
import 'package:social_media_app/core/shared/widgets/user_avatar.dart';
import 'package:social_media_app/core/shared/widgets/custom_video_player.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/features/home/widgets/comments_sheet.dart';
import 'package:social_media_app/features/profile/views/profile_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';
import 'package:social_media_app/features/profile/cubit/profile_cubit/profile_cubit.dart';
import 'package:social_media_app/core/route/app_routes.dart';

class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.post, this.isDetailView = false});
  final PostModel post;
  final bool isDetailView;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  // Like animation
  late final AnimationController _likeController;
  late final Animation<double> _likeScale;

  // Save animation
  late final AnimationController _saveController;
  late final Animation<double> _saveScale;

  // Floating heart overlay
  late final AnimationController _heartFloatController;
  late final Animation<double> _heartFloatOpacity;
  late final Animation<double> _heartFloatOffset;
  late final Animation<double> _heartFloatScale;

  bool _showFloatingHeart = false;

  @override
  void initState() {
    super.initState();

    // Like: quick pop then settle
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _likeScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.45,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.45,
          end: 0.88,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.88,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_likeController);

    // Save: spring bounce
    _saveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _saveScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.35,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.35,
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

    // Floating heart
    _heartFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _heartFloatOpacity = TweenSequence<double>([
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
    _heartFloatOffset = Tween<double>(begin: 0.0, end: -60.0).animate(
      CurvedAnimation(parent: _heartFloatController, curve: Curves.easeOut),
    );
    _heartFloatScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.5,
          end: 1.4,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 60),
    ]).animate(_heartFloatController);
  }

  @override
  void dispose() {
    _likeController.dispose();
    _saveController.dispose();
    _heartFloatController.dispose();
    super.dispose();
  }

  void _triggerLikeAnimation() {
    _likeController.forward(from: 0);
    setState(() => _showFloatingHeart = true);
    _heartFloatController.forward(from: 0).then((_) {
      if (mounted) setState(() => _showFloatingHeart = false);
    });
    HapticFeedback.lightImpact();
  }

  void _triggerSaveAnimation() {
    _saveController.forward(from: 0);
    HapticFeedback.selectionClick();
  }

  bool _hasVideo() {
    return widget.post.video != null && widget.post.video!.isNotEmpty;
  }

  void _showDeleteDialog(BuildContext context, PostModel post) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              try {
                context.read<HomeCubit>().deletePost(post.id);
              } catch (_) {
                try {
                  context.read<ProfileCubit>().deletePost(
                    post.id,
                    userId: post.authorId,
                  );
                } catch (_) {}
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, PostModel post) {
    final controller = TextEditingController(text: post.text);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const Text('Edit Post'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'What is on your mind?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newText = controller.text.trim();
              if (newText.isNotEmpty) {
                Navigator.pop(dialogContext);
                try {
                  context.read<HomeCubit>().editPost(post.id, newText);
                } catch (_) {
                  try {
                    context.read<ProfileCubit>().editPost(
                      post.id,
                      newText,
                      userId: post.authorId,
                    );
                  } catch (_) {}
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final hasPostImage = post.imageUrl != null && post.imageUrl!.isNotEmpty;
    final hasPostVideo = _hasVideo();
    final postsCubit = context.read<PostsCubit>();
    final size = MediaQuery.of(context).size;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isOwner = currentUserId != null && currentUserId == post.authorId;
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
                  // Avatar + name/time
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProfileScreen(userId: post.authorId),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Hero(
                            tag: 'avatar_${post.authorId}_${post.id}',
                            child: UserAvatar(
                              imageUrl: post.authorProfileImage,
                              name: post.authorName ?? '',
                              radius: 22.r,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.authorName ?? 'No Name',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                Row(
                                  children: [
                                    Icon(
                                      post.isPrivate
                                          ? Icons.lock_outline_rounded
                                          : Icons.public_rounded,
                                      size: 11.sp,
                                      color: AppColors.darkGrey,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      post.isPrivate ? 'Private' : 'Public',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(color: AppColors.darkGrey),
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      '·',
                                      style: TextStyle(
                                        color: AppColors.darkGrey,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      DateFormat(
                                        'h:mm a',
                                      ).format(DateTime.parse(post.createdAt)),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(color: AppColors.darkGrey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Owner menu
                  if (isOwner)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') _showEditDialog(context, post);
                        if (value == 'delete') _showDeleteDialog(context, post);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 18.sp),
                              SizedBox(width: 8.w),
                              const Text('Edit Post'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              const Text(
                                'Delete Post',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      icon: Icon(Icons.more_horiz_rounded, size: 22.sp),
                    ),
                ],
              ),
            ),

            // ── Body (tappable) ────────────────────────────────────────
            InkWell(
              onTap: widget.isDetailView
                  ? null
                  : () {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed(AppRoutes.postDetailScreen, arguments: post);
                    },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption text
                  if (post.text.trim().isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      child: Text(
                        post.text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14.5.sp,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ] else
                    SizedBox(height: 10.h),

                  // Post image – dynamic aspect ratio
                  if (hasPostImage) _DynamicImage(imageUrl: post.imageUrl!),

                  // Post video
                  if (hasPostVideo) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      child: CustomVideoPlayer(videoUrl: post.video!),
                    ),
                  ],

                  if (!hasPostImage && !hasPostVideo) SizedBox(height: 4.h),
                ],
              ),
            ),

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
                  // Like button
                  BlocBuilder<PostsCubit, PostsState>(
                    bloc: postsCubit,
                    buildWhen: (previous, current) {
                      return (current is PostLiking &&
                              current.postId == post.id) ||
                          (current is PostLiked && current.postId == post.id) ||
                          (current is PostLikeError &&
                              current.postId == post.id);
                    },
                    builder: (context, state) {
                      final isOptimisticLiked = state is PostLiked
                          ? state.isLiked
                          : state is PostLiking
                          ? !post.isLiked
                          : post.isLiked;

                      final optimisticLikesCount = state is PostLiked
                          ? state.likesCount
                          : state is PostLiking
                          ? (post.isLiked
                                ? (post.likes?.length ?? 1) - 1
                                : (post.likes?.length ?? 0) + 1)
                          : post.likes?.length ?? 0;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Animated like icon
                              AnimatedBuilder(
                                animation: _likeScale,
                                builder: (_, child) => Transform.scale(
                                  scale: _likeScale.value,
                                  child: child,
                                ),
                                child: IconButton(
                                  onPressed: state is PostLiking
                                      ? null
                                      : () async {
                                          if (!post.isLiked) {
                                            // Only show floating heart when liking
                                            _triggerLikeAnimation();
                                          } else {
                                            _likeController.forward(from: 0);
                                            HapticFeedback.selectionClick();
                                          }
                                          await postsCubit.likePost(post.id);
                                        },
                                  icon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    transitionBuilder: (child, anim) =>
                                        ScaleTransition(
                                          scale: anim,
                                          child: child,
                                        ),
                                    child: Icon(
                                      isOptimisticLiked
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      key: ValueKey(isOptimisticLiked),
                                      color: isOptimisticLiked
                                          ? AppColors.primaryColor
                                          : null,
                                      size: 25.sp,
                                    ),
                                  ),
                                  padding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(
                                    horizontal: -4,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 0,
                                    minHeight: 40.h,
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, anim) =>
                                    FadeTransition(
                                      opacity: anim,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.5),
                                          end: Offset.zero,
                                        ).animate(anim),
                                        child: child,
                                      ),
                                    ),
                                child: Text(
                                  _formatCount(optimisticLikesCount),
                                  key: ValueKey(optimisticLikesCount),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isOptimisticLiked
                                        ? AppColors.white
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Floating heart
                          if (_showFloatingHeart)
                            Positioned(
                              left: 12.w,
                              top: 0,
                              child: AnimatedBuilder(
                                animation: _heartFloatController,
                                builder: (context, _) => Opacity(
                                  opacity: _heartFloatOpacity.value,
                                  child: Transform.translate(
                                    offset: Offset(0, _heartFloatOffset.value),
                                    child: Transform.scale(
                                      scale: _heartFloatScale.value,
                                      child: Icon(
                                        Icons.favorite_rounded,
                                        color: AppColors.primaryColor,
                                        size: 20.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  SizedBox(width: 10.w),

                  // Comment button
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useRootNavigator: true,
                            backgroundColor: theme.cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20.r),
                              ),
                            ),
                            builder: (context) {
                              return SizedBox(
                                height: size.height * 0.8,
                                width: size.width,
                                child: SafeArea(
                                  child: BlocProvider.value(
                                    value: postsCubit,
                                    child: CommentsSheet(post: post),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        icon: Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 25.sp,
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: const VisualDensity(horizontal: -4),
                        constraints: BoxConstraints(
                          minWidth: 0,
                          minHeight: 40.h,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _formatCount(post.commentCount ?? 0),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Save button
                  BlocBuilder<PostsCubit, PostsState>(
                    bloc: postsCubit,
                    buildWhen: (previous, current) =>
                        current is SavedPostsLoaded,
                    builder: (context, state) {
                      final isSaved = postsCubit.savedPostIds.contains(post.id);
                      return AnimatedBuilder(
                        animation: _saveScale,
                        builder: (_, child) => Transform.scale(
                          scale: _saveScale.value,
                          child: child,
                        ),
                        child: IconButton(
                          onPressed: () {
                            _triggerSaveAnimation();
                            postsCubit.toggleSavePost(post.id);
                          },
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Icon(
                              isSaved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              key: ValueKey(isSaved),
                              color: isSaved ? AppColors.primaryColor : null,
                              size: 25.sp,
                            ),
                          ),
                          padding: EdgeInsets.zero,
                          visualDensity: const VisualDensity(horizontal: -4),
                          constraints: BoxConstraints(
                            minWidth: 0,
                            minHeight: 40.h,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

/// A widget that loads a network image at its natural aspect ratio.
/// It resolves the image dimensions asynchronously then renders the image
/// at the exact width × computed height — no fixed height, no cropping.
class _DynamicImage extends StatefulWidget {
  const _DynamicImage({required this.imageUrl});
  final String imageUrl;

  @override
  State<_DynamicImage> createState() => _DynamicImageState();
}

class _DynamicImageState extends State<_DynamicImage> {
  double? _aspectRatio; // width / height
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _resolveAspectRatio();
  }

  Future<void> _resolveAspectRatio() async {
    try {
      final imageProvider = CachedNetworkImageProvider(widget.imageUrl);
      final stream = imageProvider.resolve(ImageConfiguration.empty);
      final completer = Completer<ImageInfo>();
      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (info, synchronousCall) {
          if (!completer.isCompleted) completer.complete(info);
        },
        onError: (e, st) {
          if (!completer.isCompleted) completer.completeError(e, st);
        },
      );
      stream.addListener(listener);
      final info = await completer.future;
      stream.removeListener(listener);
      if (mounted) {
        setState(() {
          _aspectRatio =
              info.image.width.toDouble() / info.image.height.toDouble();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Container(
        height: 180.h,
        width: double.infinity,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.grey,
            size: 40,
          ),
        ),
      );
    }

    // While resolving, show a shimmer-like placeholder at a default 4:3 ratio
    if (_aspectRatio == null) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          width: double.infinity,
          color: Colors.grey[100],
          child: const Center(child: CircularProgressIndicator.adaptive()),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _aspectRatio!,
      child: CachedNetworkImage(
        imageUrl: widget.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        fadeInDuration: const Duration(milliseconds: 300),
        placeholder: (context, url) => Container(color: Colors.grey[100]),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.grey,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }
}
