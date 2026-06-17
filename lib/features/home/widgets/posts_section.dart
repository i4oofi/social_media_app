import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/shared/widgets/animated_empty_state.dart';
import 'package:social_media_app/core/shared/widgets/post_card.dart';
import 'package:social_media_app/core/shared/widgets/shimmer_loading.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';
import 'package:social_media_app/features/home/models/post_model.dart';

class PostsSection extends StatefulWidget {
  const PostsSection({super.key});

  @override
  State<PostsSection> createState() => _PostsSectionState();
}

class _PostsSectionState extends State<PostsSection> {
  List<PostModel> _posts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (_, current) =>
          current is PostLoading ||
          current is PostLoaded ||
          current is PostError,
      listener: (context, state) {
        if (state is PostLoading) {
          setState(() {
            _isLoading = true;
            _isLoadingMore = false;
            _error = null;
          });
        } else if (state is PostLoaded) {
          setState(() {
            _posts = state.posts;
            _isLoadingMore = state.isLoadingMore;
            _isLoading = false;
            _error = null;
          });
        } else if (state is PostError) {
          setState(() {
            _isLoading = false;
            _isLoadingMore = false;
            _error = state.error;
          });
        }
      },
      child: _isLoading && _posts.isEmpty
          ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (_, __) => const PostShimmer(),
            )
          : _error != null && _posts.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Center(
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : _posts.isEmpty
                  ? const AnimatedEmptyState(
                      icon: Icons.post_add_rounded,
                      title: 'No Posts',
                      subtitle: 'Be the first one to post something!',
                      // imagePath: 'assets/images/empty_home_posts.gif', // uncomment when GIF is added
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _posts.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.h),
                            child: Center(
                              child: CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.primaryColor,
                                ),
                              ),
                            ),
                          );
                        }
                        return PostCard(post: _posts[index]);
                      },
                    ),
    );
  }
}

