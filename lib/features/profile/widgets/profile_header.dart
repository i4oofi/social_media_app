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
              Container(
                width: size.width,
                height: size.height * 0.3,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      'https://images.unsplash.com/photo-1707343843437-caacff5cfa74?q=80&w=1200&auto=format&fit=crop',
                    ),
                    fit: BoxFit.cover,
                  ),
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
