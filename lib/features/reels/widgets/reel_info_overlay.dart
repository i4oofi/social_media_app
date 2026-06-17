import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/shared/widgets/user_avatar.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/features/profile/views/profile_screen.dart';
import 'package:social_media_app/features/reels/cubit/reels_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReelInfoOverlay extends StatelessWidget {
  final PostModel reel;

  ReelInfoOverlay({super.key, required this.reel});

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
      padding: EdgeInsets.all(16.0.w),
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
                    radius: 18.r,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    reel.authorName ?? 'Unknown',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
             ),
              if (!isOwner) ...[
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: () {
                    context.read<ReelsCubit>().toggleFollow(reel.authorId);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      (reel.isFollowingAuthor ?? false) ? 'Following' : 'Follow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            reel.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 20.h), // padding from bottom navigation
        ],
      ),
    );
  }
}
