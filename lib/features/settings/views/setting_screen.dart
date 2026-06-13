import 'package:flutter/material.dart';
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
    return const Scaffold(
      body: SettingsDrawer(),
    );
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

class _SettingsDrawerBodyState extends State<SettingsDrawerBody> {
  UserData? _userData;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();
    final theme = Theme.of(context);

    return Column(
      children: [
        // Drawer Header with Profile Info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.02)
                : Colors.grey.withValues(alpha: 0.04),
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor,
              ),
            ),
          ),
          child: _isLoadingUser
              ? const Center(child: CircularProgressIndicator.adaptive())
              : Row(
                  children: [
                    UserAvatar(
                      imageUrl: _userData?.imageUrl,
                      name: _userData?.name ?? "",
                      radius: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _userData?.name ?? "User",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _userData?.title ?? "No title set",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey[400]
                                  : AppColors.darkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),

        // Navigation Items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            children: [
              // Theme Mode Toggle
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  final isDark = themeMode == ThemeMode.dark ||
                      (themeMode == ThemeMode.system &&
                          MediaQuery.platformBrightnessOf(context) ==
                              Brightness.dark);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Icon(
                        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : AppColors.black,
                        size: 22,
                      ),
                      title: const Text(
                        "Dark Mode",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      trailing: Switch.adaptive(
                        value: isDark,
                        activeColor: AppColors.primaryColor,
                        onChanged: (val) {
                          context.read<ThemeCubit>().toggleTheme(val);
                        },
                      ),
                    ),
                  );
                },
              ),
              _buildDrawerTile(
                context: context,
                icon: Icons.person_outline_rounded,
                title: "Edit Profile",
                onTap: () {
                  if (_userData != null) {
                    Navigator.of(context).pop(); // Close drawer
                    Navigator.pushNamed(
                      context,
                      AppRoutes.editProfile,
                      arguments: EditProfileScreenArgs(userData: _userData!),
                    );
                  } else {
                    AppToast.showToast(
                      msg: "Profile data is still loading...",
                      backgroundColor: AppColors.red,
                    );
                  }
                },
              ),
              _buildDrawerTile(
                context: context,
                icon: Icons.bookmark_border_rounded,
                title: "Saved Posts",
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context , rootNavigator: true).pushNamed(AppRoutes.savedPosts);
                },
              ),
              _buildDrawerTile(
                context: context,
                icon: Icons.lock_outline_rounded,
                title: "Privacy & Security",
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              _buildDrawerTile(
                context: context,
                icon: Icons.notifications_none_rounded,
                title: "Notifications",
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              _buildDrawerTile(
                context: context,
                icon: Icons.help_outline_rounded,
                title: "Help & Support",
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),

        // Bottom section with Logout
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: theme.dividerColor,
              ),
            ),
          ),
          child: BlocConsumer<SettingsCubit, SettingsState>(
            listenWhen: (previous, current) =>
                current is SignOutSuccess || current is SignOutFailure,
            listener: (context, state) {
              if (state is SignOutSuccess) {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamedAndRemoveUntil(
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
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () async {
                    await settingsCubit.signOut();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.red,
                  ),
                  title: const Text(
                    "Logout",
                    style: TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icon,
          color: theme.brightness == Brightness.dark ? Colors.white : AppColors.black,
          size: 22,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: theme.brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.4)
              : AppColors.darkGrey.withValues(alpha: 0.5),
          size: 14,
        ),
      ),
    );
  }
}

