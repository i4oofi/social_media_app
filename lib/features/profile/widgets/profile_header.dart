import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/core/shared/widgets/user_avatar.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/features/auth/widgets/main_button.dart';
import 'package:social_media_app/features/profile/cubit/profile_cubit/profile_cubit.dart';
import 'package:social_media_app/features/profile/models/edit_profile_screen_args.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({
    super.key,
    required this.userData,
    this.isPrivate = true,
  });
  final UserData userData;
  final bool isPrivate;

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader>
    with TickerProviderStateMixin {
  // Entrance animations
  late final AnimationController _entranceController;
  late final Animation<double> _avatarScale;
  late final Animation<double> _avatarFade;
  late final Animation<Offset> _infoSlide;
  late final Animation<double> _infoFade;
  late final Animation<Offset> _buttonsSlide;
  late final Animation<double> _buttonsFade;

  // Follow button press scale
  late final AnimationController _followPressController;
  late final Animation<double> _followScale;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _avatarScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    _avatarFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _infoSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
          ),
        );
    _infoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );
    _buttonsSlide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
          ),
        );
    _buttonsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _followPressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _followScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _followPressController, curve: Curves.easeInOut),
    );

    // Start entrance
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _followPressController.dispose();
    super.dispose();
  }

  void _openAvatarViewer(BuildContext context) {
    if (widget.userData.imageUrl == null) return;
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) =>
            _AvatarViewerPage(imageUrl: widget.userData.imageUrl!),
        transitionsBuilder: (context, anim, secondaryAnim, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();
    final size = MediaQuery.sizeOf(context);
    final currentUserId =
        profileCubit.coreAuthServices.supabase.auth.currentUser?.id;
    final isFollowing =
        widget.userData.followers?.contains(currentUserId ?? '') ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ── Cover + Avatar ────────────────────────────────────────────
        SizedBox(
          height: size.height * 0.3 + 44,
          child: Stack(
            children: [
              // Cover photo
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
                child: widget.userData.coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: widget.userData.coverUrl!,
                        width: size.width,
                        height: size.height * 0.3,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _CoverPlaceholder(
                          width: size.width,
                          height: size.height * 0.3,
                          isPrivate: widget.isPrivate,
                          isLoading: true,
                          userName: widget.userData.name,
                        ),
                        errorWidget: (context, url, error) => _CoverPlaceholder(
                          width: size.width,
                          height: size.height * 0.3,
                          isPrivate: widget.isPrivate,
                          isLoading: false,
                          userName: widget.userData.name,
                        ),
                      )
                    : _CoverPlaceholder(
                        width: size.width,
                        height: size.height * 0.3,
                        isPrivate: widget.isPrivate,
                        isLoading: false,
                        userName: widget.userData.name,
                      ),
              ),

              // Back button
              if (Navigator.of(context).canPop())
                Positioned(
                  top: 12,
                  left: 12,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),

              // Avatar (centered, animated entrance + hold-to-view)
              Positioned(
                bottom: 0,
                left: size.width * 0.5 - 62,
                right: size.width * 0.5 - 62,
                child: AnimatedBuilder(
                  animation: _entranceController,
                  builder: (_, child) => Opacity(
                    opacity: _avatarFade.value,
                    child: Transform.scale(
                      scale: _avatarScale.value,
                      child: child,
                    ),
                  ),
                  child: GestureDetector(
                    onLongPress: () => _openAvatarViewer(context),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.35,
                            ),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: UserAvatar(
                        imageUrl: widget.userData.imageUrl,
                        name: widget.userData.name,
                        radius: 62.r,
                        showBorder: true,
                        borderColor: Colors.white,
                        borderWidth: 3.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Name / Username ───────────────────────────────────────────
        SlideTransition(
          position: _infoSlide,
          child: FadeTransition(
            opacity: _infoFade,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  SizedBox(height: 10.h),
                  Text(
                    widget.userData.name,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '@${widget.userData.userName}',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                      if (widget.userData.title != null &&
                          widget.userData.title!.isNotEmpty) ...[
                        Text(
                          '  ·  ',
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 13.sp,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            widget.userData.title!,
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  color: AppColors.darkGrey,
                                  fontStyle: FontStyle.italic,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),

        // ── Action Buttons ────────────────────────────────────────────
        SlideTransition(
          position: _buttonsSlide,
          child: FadeTransition(
            opacity: _buttonsFade,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: widget.isPrivate
                  ? _OwnProfileActions(
                      userData: widget.userData,
                      profileCubit: profileCubit,
                      isDark: isDark,
                      size: size,
                    )
                  : _OtherProfileActions(
                      userData: widget.userData,
                      profileCubit: profileCubit,
                      isFollowing: isFollowing,
                      followScale: _followScale,
                      followPressController: _followPressController,
                      size: size,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Own profile action buttons ─────────────────────────────────────────────────

class _OwnProfileActions extends StatelessWidget {
  final UserData userData;
  final ProfileCubit profileCubit;
  final bool isDark;
  final Size size;

  const _OwnProfileActions({
    required this.userData,
    required this.profileCubit,
    required this.isDark,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MainButton(
          text: 'EDIT PROFILE',
          width: size.width * 0.5,
          transparent: true,
          onPressed: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(
                  AppRoutes.editProfile,
                  arguments: EditProfileScreenArgs(userData: userData),
                )
                .then((_) async {
                  await profileCubit.fetchUserProfile();
                  await profileCubit.fetchUserPosts();
                });
          },
        ),
        SizedBox(width: 12.w),
        _IconActionButton(
          icon: Icons.settings_rounded,
          isDark: isDark,
          onTap: () => Scaffold.of(context).openDrawer(),
        ),
      ],
    );
  }
}

// ── Other user's profile action buttons ───────────────────────────────────────

class _OtherProfileActions extends StatelessWidget {
  final UserData userData;
  final ProfileCubit profileCubit;
  final bool isFollowing;
  final Animation<double> followScale;
  final AnimationController followPressController;
  final Size size;

  const _OtherProfileActions({
    required this.userData,
    required this.profileCubit,
    required this.isFollowing,
    required this.followScale,
    required this.followPressController,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated follow button
        ScaleTransition(
          scale: followScale,
          child: GestureDetector(
            onTapDown: (_) => followPressController.forward(),
            onTapUp: (_) async {
              await followPressController.reverse();
              if (context.mounted) {
                await profileCubit.toggleFollowUser(userData.id);
              }
            },
            onTapCancel: () => followPressController.reverse(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: size.width * 0.4,
              height: 48.h,
              decoration: BoxDecoration(
                color: isFollowing
                    ? Colors.transparent
                    : AppColors.primaryColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isFollowing ? AppColors.grey : AppColors.primaryColor,
                  width: 1.5,
                ),
                boxShadow: isFollowing
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: TextStyle(
                    color: isFollowing ? AppColors.darkGrey : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        _OutlineActionButton(
          label: 'Message',
          icon: Icons.send_rounded,
          width: size.width * 0.4,
          onTap: () {
            Navigator.of(context, rootNavigator: true).pushNamed(
              AppRoutes.chatRoomScreen,
              arguments: {'otherUserId': userData.id},
            );
          },
        ),
      ],
    );
  }
}

// ── Small reusable icon button ─────────────────────────────────────────────────

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        width: 48.w,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey, width: 1.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : Colors.black87,
          size: 20.sp,
        ),
      ),
    );
  }
}

// ── Outline action button ──────────────────────────────────────────────────────

class _OutlineActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final double width;
  final VoidCallback onTap;

  const _OutlineActionButton({
    required this.label,
    required this.icon,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 48.h,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey, width: 1.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.sp, color: AppColors.darkGrey),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Full-screen avatar viewer with pinch-to-zoom ───────────────────────────────

class _AvatarViewerPage extends StatefulWidget {
  final String imageUrl;
  const _AvatarViewerPage({required this.imageUrl});

  @override
  State<_AvatarViewerPage> createState() => _AvatarViewerPageState();
}

class _AvatarViewerPageState extends State<_AvatarViewerPage>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformController =
      TransformationController();
  late final AnimationController _resetController;
  Animation<Matrix4>? _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        )..addListener(() {
          if (_resetAnimation != null) {
            _transformController.value = _resetAnimation!.value;
          }
        });
  }

  @override
  void dispose() {
    _transformController.dispose();
    _resetController.dispose();
    super.dispose();
  }

  void _onDoubleTap(TapDownDetails details) {
    final current = _transformController.value;
    final isZoomedIn = current.getMaxScaleOnAxis() > 1.5;

    final target = isZoomedIn
        ? Matrix4.identity()
        : (Matrix4.translationValues(
            -details.localPosition.dx,
            -details.localPosition.dy,
            0,
          )..scaleByDouble(2.5, 2.5, 1.0, 1.0));

    _resetAnimation = Matrix4Tween(begin: current, end: target).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeInOut),
    );
    _resetController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Background dismiss tap
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black87),
            ),

            // Zoomable image
            Center(
              child: GestureDetector(
                onDoubleTapDown: _onDoubleTap,
                onDoubleTap: () {},
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 0.8,
                  maxScale: 5.0,
                  clipBehavior: Clip.none,
                  child: Hero(
                    tag: 'avatar_viewer_${widget.imageUrl}',
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        width: 300.w,
                        height: 300.w,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 300.w,
                          height: 300.w,
                          color: Colors.grey[900],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Close button
            Positioned(
              top: 12,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cover Placeholder
// ─────────────────────────────────────────────────────────────────────────────
class _CoverPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final bool isPrivate;
  final bool isLoading;
  final String userName;

  const _CoverPlaceholder({
    required this.width,
    required this.height,
    required this.isPrivate,
    required this.isLoading,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0779B8), Color(0xFF003D6B)],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white54,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (isPrivate) {
      return Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0779B8), Color(0xFF005FA3), Color(0xFF003D6B)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1.5.w,
                ),
              ),
              child: Icon(
                Icons.add_photo_alternate_outlined,
                size: 32.h,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Add a Cover Photo',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Tap "Edit Profile" to add one',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      );
    }

    // Public cover placeholder — initials watermark
    final initials = userName
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 160.w,
              height: 160.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0779B8).withValues(alpha: 0.18),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Center(
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 72.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white.withValues(alpha: 0.08),
                letterSpacing: 8,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
