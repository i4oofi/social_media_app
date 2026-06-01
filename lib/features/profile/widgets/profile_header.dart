import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/features/auth/widgets/main_button.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.userData});
  final UserData userData;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
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
                      'https://www.presidency.eg/media/93877/%D8%A7%D9%84%D8%B1%D8%A6%D9%8A%D8%B3-%D8%B9%D8%A8%D8%AF-%D8%A7%D9%84%D9%81%D8%AA%D8%A7%D8%AD-%D8%A7%D9%84%D8%B3%D9%8A%D8%B3%D9%8A-black-one-finljpg.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
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
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryColor, width: 3),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: userData.imageUrl ?? '',
                    imageBuilder: (context, imageProvider) => Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
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
              MainButton(
                text: 'EDIT PROFILE',
                width: size.width * 0.5,
                transparent: true,
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.editProfile);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
