import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:social_media_app/core/services/post_services.dart';
import 'package:social_media_app/features/discover/views/discover_screen.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';
import 'package:social_media_app/features/home/views/home_screen.dart';
import 'package:social_media_app/features/profile/views/profile_screen.dart';
import 'package:social_media_app/features/reels/cubit/reels_cubit.dart';
import 'package:social_media_app/features/reels/views/reels_screen.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:social_media_app/core/theme/app_colors.dart';

class CustomBottomNavbar extends StatefulWidget {
  const CustomBottomNavbar({super.key});

  @override
  State<CustomBottomNavbar> createState() => _CustomBottomNavbarState();
}

class _CustomBottomNavbarState extends State<CustomBottomNavbar>
    with SingleTickerProviderStateMixin {
  UserData? currentUser;

  late final AnimationController _entranceController;
  late final Animation<Offset> _slideUp;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fetchUser();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _fade = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _fetchUser() async {
    final user = await CoreAuthServices().getCurrentUserData();
    if (mounted) setState(() => currentUser = user);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = AppColors.primaryColor;
    final inactiveColor =
        theme.brightness == Brightness.dark ? Colors.white54 : Colors.black38;

    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (context) => HomeCubit()
            ..fetchStories()
            ..fetchPosts(),
        ),
        BlocProvider<ReelsCubit>(
          create: (context) => ReelsCubit(PostServices())..fetchReels(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return SlideTransition(
            position: _slideUp,
            child: FadeTransition(
              opacity: _fade,
              child: PersistentTabView(
                tabs: [
                  PersistentTabConfig(
                    screen: const HomeScreen(),
                    item: ItemConfig(
                      icon: _AnimatedNavIcon(
                        icon: Icons.home_rounded,
                        onDoubleTap: () {
                          HapticFeedback.lightImpact();
                          context.read<HomeCubit>().refresh();
                        },
                      ),
                      title: 'Home',
                      activeForegroundColor: activeColor,
                      inactiveForegroundColor: inactiveColor,
                    ),
                  ),
                  PersistentTabConfig(
                    screen: const DiscoverScreen(),
                    item: ItemConfig(
                      icon: const _AnimatedNavIcon(
                          icon: Icons.explore_rounded),
                      title: 'Discover',
                      activeForegroundColor: activeColor,
                      inactiveForegroundColor: inactiveColor,
                    ),
                  ),
                  PersistentTabConfig(
                    screen: const ReelsScreen(),
                    item: ItemConfig(
                      icon: _AnimatedNavIcon(
                        icon: Icons.smart_display_rounded,
                        onDoubleTap: () {
                          HapticFeedback.lightImpact();
                          context
                              .read<ReelsCubit>()
                              .fetchReels(refresh: true);
                        },
                      ),
                      title: 'Reels',
                      activeForegroundColor: activeColor,
                      inactiveForegroundColor: inactiveColor,
                    ),
                  ),
                  PersistentTabConfig(
                    screen: const ProfileScreen(),
                    item: ItemConfig(
                      icon: currentUser?.imageUrl != null
                          ? _ProfileAvatar(imageUrl: currentUser!.imageUrl!)
                          : const _AnimatedNavIcon(
                              icon: Icons.person_rounded),
                      title: 'Profile',
                      activeForegroundColor: activeColor,
                      inactiveForegroundColor: inactiveColor,
                    ),
                  ),
                ],
                navBarBuilder: (navBarConfig) => Style5BottomNavBar(
                  navBarConfig: navBarConfig,
                  navBarDecoration: NavBarDecoration(
                    color: theme.cardColor,
                    border: Border(
                      top: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.25),
                        width: 0.5.w,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedNavIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onDoubleTap;

  const _AnimatedNavIcon({required this.icon, this.onDoubleTap});

  @override
  State<_AnimatedNavIcon> createState() => _AnimatedNavIconState();
}

class _AnimatedNavIconState extends State<_AnimatedNavIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  DateTime? _lastTap;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 0.92)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.92, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    _ctrl.forward(from: 0);
    if (widget.onDoubleTap != null) {
      final now = DateTime.now();
      if (_lastTap != null &&
          now.difference(_lastTap!).inMilliseconds < 380) {
        widget.onDoubleTap!();
        _lastTap = null;
      } else {
        _lastTap = now;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Icon(widget.icon),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  const _ProfileAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26.w,
      height: 26.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryColor, width: 2),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
              color: AppColors.primaryColor.withValues(alpha: 0.2)),
          errorWidget: (context, url, error) =>
              Icon(Icons.person_rounded, size: 14.sp),
        ),
      ),
    );
  }
}
