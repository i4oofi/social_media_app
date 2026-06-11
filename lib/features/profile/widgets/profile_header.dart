import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/core/shared/widgets/user_avatar.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/features/auth/widgets/main_button.dart';
import 'package:social_media_app/features/profile/cubit/profile_cubit/profile_cubit.dart';
import 'package:social_media_app/features/profile/models/edit_profile_screen_args.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.userData, this.isPrivate = true});
  final UserData userData;
  final bool isPrivate;
  @override
  Widget build(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();
    final size = MediaQuery.sizeOf(context);
    final currentUserId = profileCubit.coreAuthServices.supabase.auth.currentUser?.id;
    final isFollowing = userData.followers?.contains(currentUserId ?? '') ?? false;

    return Column(
      children: [
        SizedBox(
          height: size.height * 0.3 + 40,
          child: Stack(
            children: [
              // ── Cover Photo ──────────────────────────────────────
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                child: userData.coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: userData.coverUrl!,
                        width: size.width,
                        height: size.height * 0.3,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _CoverPlaceholder(
                          width: size.width,
                          height: size.height * 0.3,
                          isPrivate: isPrivate,
                          isLoading: true,
                          userName: userData.name,
                        ),
                        errorWidget: (context, url, error) => _CoverPlaceholder(
                          width: size.width,
                          height: size.height * 0.3,
                          isPrivate: isPrivate,
                          isLoading: false,
                          userName: userData.name,
                        ),
                      )
                    : _CoverPlaceholder(
                        width: size.width,
                        height: size.height * 0.3,
                        isPrivate: isPrivate,
                        isLoading: false,
                        userName: userData.name,
                      ),
              ),
              if (Navigator.of(context).canPop())
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: size.width * 0.5 - 60,
                right: size.width * 0.5 - 60,
                child: UserAvatar(
                  imageUrl: userData.imageUrl,
                  name: userData.name,
                  radius: 60,
                  showBorder: true,
                  borderColor: AppColors.primaryColor,
                  borderWidth: 3,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Text(
                userData.name,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                userData.title ?? 'No title',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              if (isPrivate)
                Row(
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
                            .then((value) async {
                              await profileCubit.fetchUserProfile();
                              await profileCubit.fetchUserPosts();
                            });
                      },
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(color: AppColors.grey, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        icon: const Icon(Icons.settings, color: AppColors.black),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MainButton(
                      text: isFollowing ? 'FOLLOWING' : 'FOLLOW',
                      width: size.width * 0.4,
                      transparent: isFollowing,
                      onPressed: () async {
                        await profileCubit.toggleFollowUser(userData.id);
                      },
                    ),
                    const SizedBox(width: 12),
                    MainButton(
                      text: 'MESSAGE',
                      width: size.width * 0.4,
                      transparent: true,
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pushNamed(
                          AppRoutes.chatRoomScreen,
                          arguments: {
                            'otherUserId': userData.id,
                          },
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cover Placeholder
//
// • isPrivate = true  → own profile: dashed border + camera icon + CTA text
// • isPrivate = false → public profile: subtle gradient + translucent initials
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
          child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
        ),
      );
    }

    // ── Own profile (private) ─────────────────────────────────────────────
    if (isPrivate) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0779B8), Color(0xFF005FA3), Color(0xFF003D6B)],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add a Cover Photo',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap "Edit Profile" to add one',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    // ── Public profile (other user) ───────────────────────────────────────
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
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
            Color(0xFF0f3460),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative blurred circle top-right
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0779B8).withValues(alpha: 0.18),
              ),
            ),
          ),
          // Decorative blurred circle bottom-left
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Centered initials
          Center(
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 72,
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
