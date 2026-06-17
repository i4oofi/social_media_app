import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';
import 'package:social_media_app/features/home/widgets/home_screen_header.dart';
import 'package:social_media_app/features/home/widgets/post_writing_card.dart';
import 'package:social_media_app/features/home/widgets/posts_section.dart';
import 'package:social_media_app/features/home/widgets/stories_section.dart';
import 'package:social_media_app/features/settings/views/setting_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SettingsDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<HomeCubit>().refresh();
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
                context.read<HomeCubit>().loadMorePosts();
              }
              return false;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    const HomeScreenHeader(),
                    SizedBox(height: 16.h),
                    const PostWritingCard(),
                    SizedBox(height: 24.h),
                    const StoriesSection(),
                    const PostsSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
