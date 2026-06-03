import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/shared/widgets/post_card.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/features/profile/cubit/profile_cubit.dart';

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key, required this.userData});
  final UserData userData;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Posts'),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ProfileDetails(user: userData),
                ProfilePosts(user: userData),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileDetails extends StatelessWidget {
  const ProfileDetails({super.key, required this.user});
  final UserData user;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Text("Profile Details"),
            Divider(),
            Text("Email: ${user.email}"),
            Text("Name: ${user.name}"),
            Text("Bio: ${user.title}"),
          ],
        ),
      ),
    );
  }
}

class ProfilePosts extends StatelessWidget {
  const ProfilePosts({super.key, required this.user});
  final UserData user;
  @override
  Widget build(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();
    return BlocBuilder<ProfileCubit, ProfileState>(
      bloc: profileCubit,
      buildWhen: (previous, current) =>
          current is ProfilePostsLoading ||
          current is ProfilePostsSuccess ||
          current is ProfilePostsFailure,
      builder: (context, state) {
        if (state is ProfilePostsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProfilePostsFailure) {
          return Center(child: Text(state.message));
        }
        if (state is ProfilePostsSuccess) {
          final posts = state.posts;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Column(children: [PostCard(post: post)]);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
