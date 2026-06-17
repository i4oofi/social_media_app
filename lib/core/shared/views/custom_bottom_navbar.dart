import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

class _CustomBottomNavbarState extends State<CustomBottomNavbar> {
  UserData? currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final user = await CoreAuthServices().getCurrentUserData();
    if (mounted) {
      setState(() {
        currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = AppColors.primaryColor;
    final inactiveColor = theme.brightness == Brightness.dark
        ? Colors.white54
        : Colors.black45;

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
          return PersistentTabView(
            tabs: [
              PersistentTabConfig(
                screen: const HomeScreen(),
                item: ItemConfig(
                  icon: _DoubleTapIcon(
                    onDoubleTap: () => context.read<HomeCubit>().refresh(),
                    child: Icon(Icons.home),
                  ),
                  title: "Home",
                  activeForegroundColor: activeColor,
                  inactiveForegroundColor: inactiveColor,
                ),
              ),
              PersistentTabConfig(
                screen: const DiscoverScreen(),
                item: ItemConfig(
                  icon: Icon(Icons.group_add_rounded),
                  title: "Discover",
                  activeForegroundColor: activeColor,
                  inactiveForegroundColor: inactiveColor,
                ),
              ),
              PersistentTabConfig(
                screen: const ReelsScreen(),
                item: ItemConfig(
                  icon: _DoubleTapIcon(
                    onDoubleTap: () =>
                        context.read<ReelsCubit>().fetchReels(refresh: true),
                    child: Icon(Icons.video_collection_rounded),
                  ),
                  title: "Reels",
                  activeForegroundColor: activeColor,
                  inactiveForegroundColor: inactiveColor,
                ),
              ),
              PersistentTabConfig(
                screen: const ProfileScreen(),
                item: ItemConfig(
                  icon: currentUser?.imageUrl != null
                      ? CircleAvatar(
                          radius: 12.r,
                          backgroundImage:
                              CachedNetworkImageProvider(currentUser!.imageUrl!),
                        )
                      : Icon(Icons.person),
                  title: "Profile",
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
                    color: theme.dividerColor.withValues(alpha: 0.3),
                    width: 0.5.w,
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

/// A widget that wraps a child with a double-tap detector using [Listener]
/// (raw pointer events) so it doesn't compete with the nav bar's gesture arena.
class _DoubleTapIcon extends StatefulWidget {
  final Widget child;
  final VoidCallback onDoubleTap;

  const _DoubleTapIcon({required this.child, required this.onDoubleTap});

  @override
  State<_DoubleTapIcon> createState() => _DoubleTapIconState();
}

class _DoubleTapIconState extends State<_DoubleTapIcon> {
  DateTime? _lastTap;

  void _onPointerDown(PointerDownEvent event) {
    final now = DateTime.now();
    if (_lastTap != null &&
        now.difference(_lastTap!).inMilliseconds < 380) {
      widget.onDoubleTap();
      _lastTap = null;
    } else {
      _lastTap = now;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      child: widget.child,
    );
  }
}
