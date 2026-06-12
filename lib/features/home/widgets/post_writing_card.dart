import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';

class PostWritingCard extends StatefulWidget {
  const PostWritingCard({super.key});

  @override
  State<PostWritingCard> createState() => _PostWritingCardState();
}

class _PostWritingCardState extends State<PostWritingCard> {
  UserData? _currentUser;
  bool _isLoadingUser = true;
  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final user = await CoreAuthServices().getCurrentUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeCubit = context.read<HomeCubit>();
    Future<void> navigatorToPost() => Navigator.of(context, rootNavigator: true)
        .pushNamed(AppRoutes.createPost, arguments: homeCubit)
        .then((value) async => await homeCubit.refresh());
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.babyBlue5,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: _currentUser?.imageUrl != null
                    ? CachedNetworkImageProvider(_currentUser!.imageUrl!)
                    : null,
                radius: 20,
                backgroundColor: Colors.grey[200],
                child: _isLoadingUser
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      )
                    : _currentUser?.imageUrl != null
                    ? null
                    : const Icon(Icons.person, color: Colors.grey),
              ),

              const SizedBox(width: 16),
              InkWell(
                onTap: () {
                  navigatorToPost();
                },
                child: Text(
                  "What's on your head?",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  navigatorToPost();
                },
                child: Row(
                  children: [
                    Icon(Icons.image, color: AppColors.indicatorColor),
                    const SizedBox(width: 8),
                    Text(
                      "Photo",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 15,
                child: VerticalDivider(color: AppColors.black, thickness: 1),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () {
                  navigatorToPost();
                },
                child: Row(
                  children: [
                    Icon(Icons.video_file, color: AppColors.indicatorColor),
                    const SizedBox(width: 8),
                    Text(
                      "Video",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
