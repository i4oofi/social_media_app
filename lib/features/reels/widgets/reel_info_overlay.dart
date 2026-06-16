import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/shared/widgets/user_avatar.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/features/profile/views/profile_screen.dart';
import 'package:social_media_app/features/reels/cubit/reels_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReelInfoOverlay extends StatelessWidget {
  final PostModel reel;

  const ReelInfoOverlay({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isOwner = currentUserId != null && currentUserId == reel.authorId;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.black87],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector( onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen(userId: reel.authorId),
                      ),
                    );
                  },
                child: Row(
                children: [
                  UserAvatar(
                    imageUrl: reel.authorProfileImage,
                    name: reel.authorName ?? 'Unknown',
                    radius: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    reel.authorName ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
             ),
              if (!isOwner) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    context.read<ReelsCubit>().toggleFollow(reel.authorId);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      (reel.isFollowingAuthor ?? false) ? 'Following' : 'Follow',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
          const SizedBox(height: 10),
          Text(
            reel.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20), // padding from bottom navigation
        ],
      ),
    );
  }
}
