import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/core/shared/widgets/user_avatar.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/features/profile/models/edit_profile_screen_args.dart';
import 'package:social_media_app/features/settings/cubit/settings_cubit.dart';
import 'package:social_media_app/core/shared/widgets/app_toast.dart';
import 'package:social_media_app/core/cubit/theme_cubit/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SettingsDrawer());
  }
}

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: BlocProvider(
        create: (context) => SettingsCubit(),
        child: const SettingsDrawerBody(),
      ),
    );
  }
}

class SettingsDrawerBody extends StatefulWidget {
  const SettingsDrawerBody({super.key});

  @override
  State<SettingsDrawerBody> createState() => _SettingsDrawerBodyState();
}

class _SettingsDrawerBodyState extends State<SettingsDrawerBody>
    with SingleTickerProviderStateMixin {
  UserData? _userData;
  bool _isLoadingUser = true;

  late final AnimationController _entranceCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final List<Animation<double>> _itemFades;
  late final List<Animation<Offset>> _itemSlides;

  static const int _itemCount = 6; // theme toggle + 5 tiles

  @override
  void initState() {
    super.initState();
    _loadUserData();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _headerFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    _itemFades = List.generate(_itemCount, (i) {
      final start = 0.2 + i * 0.09;
      final end = (start + 0.25).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _itemSlides = List.generate(_itemCount, (i) {
      final start = 0.2 + i * 0.09;
      final end = (start + 0.25).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0.2, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await CoreAuthServices().getCurrentUserData();
      if (mounted) {
        setState(() {
          _userData = data;
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingUser = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // ── Animated Header ────────────────────────────────────────────
        FadeTransition(
          opacity: _headerFade,
          child: SlideTransition(
            position: _headerSlide,
            child: _DrawerHeader(
              userData: _userData,
              isLoading: _isLoadingUser,
              isDark: isDark,
              theme: theme,
            ),
          ),
        ),

        // ── Navigation Items ───────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            children: [
              // Theme toggle
              _FadeSlide(
                fade: _itemFades[0],
                slide: _itemSlides[0],
                child: BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) {
                    final dark = themeMode == ThemeMode.dark ||
                        (themeMode == ThemeMode.system &&
                            MediaQuery.platformBrightnessOf(context) ==
                                Brightness.dark);
                    return _ThemeToggleTile(isDark: dark, theme: theme);
                  },
                ),
              ),

              _FadeSlide(
                fade: _itemFades[1],
                slide: _itemSlides[1],
                child: _DrawerTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit Profile',
                  isDark: isDark,
                  onTap: () {
                    if (_userData != null) {
                      Navigator.of(context).pop();
                      Navigator.of(context, rootNavigator: true).pushNamed(
                        AppRoutes.editProfile,
                        arguments:
                            EditProfileScreenArgs(userData: _userData!),
                      );
                    } else {
                      AppToast.showToast(
                        msg: 'Profile data is still loading...',
                        backgroundColor: AppColors.red,
                      );
                    }
                  },
                ),
              ),

              _FadeSlide(
                fade: _itemFades[2],
                slide: _itemSlides[2],
                child: _DrawerTile(
                  icon: Icons.bookmark_border_rounded,
                  title: 'Saved Posts',
                  isDark: isDark,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context, rootNavigator: true)
                        .pushNamed(AppRoutes.savedPosts);
                  },
                ),
              ),

              _FadeSlide(
                fade: _itemFades[3],
                slide: _itemSlides[3],
                child: _DrawerTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Privacy & Security',
                  isDark: isDark,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),

              _FadeSlide(
                fade: _itemFades[4],
                slide: _itemSlides[4],
                child: _DrawerTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  isDark: isDark,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),

              _FadeSlide(
                fade: _itemFades[5],
                slide: _itemSlides[5],
                child: _DrawerTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  isDark: isDark,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),

        // ── Logout ─────────────────────────────────────────────────────
        _LogoutSection(settingsCubit: settingsCubit, theme: theme),
      ],
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  final UserData? userData;
  final bool isLoading;
  final bool isDark;
  final ThemeData theme;

  const _DrawerHeader({
    required this.userData,
    required this.isLoading,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 48.h, 20.w, 20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0779B8).withValues(alpha: 0.18),
                  Colors.transparent,
                ]
              : [
                  AppColors.primaryColor.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
        ),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: isLoading
          ? Center(
              child: SizedBox(
                height: 28.h,
                width: 28.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryColor,
                ),
              ),
            )
          : Row(
              children: [
                // Avatar with glow
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.25),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: UserAvatar(
                    imageUrl: userData?.imageUrl,
                    name: userData?.name ?? '',
                    radius: 28.r,
                    showBorder: true,
                    borderColor: AppColors.primaryColor,
                    borderWidth: 2,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userData?.name ?? 'User',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '@${userData?.userName ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (userData?.title != null &&
                          userData!.title!.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          userData!.title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.darkGrey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Theme Toggle Tile ──────────────────────────────────────────────────────────

class _ThemeToggleTile extends StatelessWidget {
  final bool isDark;
  final ThemeData theme;

  const _ThemeToggleTile({required this.isDark, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: ListTile(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r)),
        leading: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            key: ValueKey(isDark),
            color: isDark ? Colors.amber : Colors.orange,
            size: 22.sp,
          ),
        ),
        title: Text(
          'Dark Mode',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
        trailing: Switch.adaptive(
          value: isDark,
          activeThumbColor: AppColors.primaryColor,
          onChanged: (val) {
            HapticFeedback.selectionClick();
            context.read<ThemeCubit>().toggleTheme(val);
          },
        ),
      ),
    );
  }
}

// ── Drawer Tile ────────────────────────────────────────────────────────────────

class _DrawerTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDark;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_DrawerTile> createState() => _DrawerTileState();
}

class _DrawerTileState extends State<_DrawerTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) async {
          await _pressCtrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: ScaleTransition(
          scale: _pressScale,
          child: ListTile(
            onTap: null, // handled by GestureDetector above
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            leading: Icon(
              widget.icon,
              color: widget.isDark ? Colors.white : AppColors.black,
              size: 22.sp,
            ),
            title: Text(
              widget.title,
              style:
                  TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.35)
                  : AppColors.darkGrey.withValues(alpha: 0.45),
              size: 13.sp,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Logout Section ─────────────────────────────────────────────────────────────

class _LogoutSection extends StatefulWidget {
  final SettingsCubit settingsCubit;
  final ThemeData theme;

  const _LogoutSection(
      {required this.settingsCubit, required this.theme});

  @override
  State<_LogoutSection> createState() => _LogoutSectionState();
}

class _LogoutSectionState extends State<_LogoutSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                color: widget.theme.dividerColor.withValues(alpha: 0.4))),
      ),
      child: BlocConsumer<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) =>
            current is SignOutSuccess || current is SignOutFailure,
        listener: (context, state) {
          if (state is SignOutSuccess) {
            Navigator.of(context, rootNavigator: true)
                .pushNamedAndRemoveUntil(
              AppRoutes.authScreen,
              (route) => false,
            );
          } else if (state is SignOutFailure) {
            AppToast.showToast(
              msg: state.error,
              backgroundColor: AppColors.red,
            );
          }
        },
        buildWhen: (previous, current) =>
            current is SignOutLoading ||
            current is SignOutSuccess ||
            current is SignOutFailure,
        builder: (context, state) {
          if (state is SignOutLoading) {
            return Center(
              child: SizedBox(
                height: 24.h,
                width: 24.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.red,
                ),
              ),
            );
          }
          return GestureDetector(
            onTapDown: (_) => _pressCtrl.forward(),
            onTapUp: (_) async {
              await _pressCtrl.reverse();
              HapticFeedback.mediumImpact();
              await widget.settingsCubit.signOut();
            },
            onTapCancel: () => _pressCtrl.reverse(),
            child: ScaleTransition(
              scale: _pressScale,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.red.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  leading: Icon(Icons.logout_rounded,
                      color: AppColors.red, size: 22.sp),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
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

// ── Fade + Slide wrapper ───────────────────────────────────────────────────────

class _FadeSlide extends StatelessWidget {
  final Animation<double> fade;
  final Animation<Offset> slide;
  final Widget child;

  const _FadeSlide(
      {required this.fade, required this.slide, required this.child});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}
