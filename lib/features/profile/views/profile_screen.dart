import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/profile/cubit/private_profile_cubit.dart';
import 'package:social_media_app/features/profile/widgets/profile_body.dart';
import 'package:social_media_app/features/profile/widgets/profile_header.dart';
import 'package:social_media_app/features/profile/widgets/profile_stats.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PrivateProfileCubit()..fetchUserProfile(),
      child: BlocBuilder<PrivateProfileCubit, PrivateProfileState>(
        buildWhen: (previous, current) =>
            current is! ProfileLoading ||
            current is! ProfileSuccess ||
            current is! ProfileFailure,
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileFailure) {
            return Center(child: Text(state.message));
          }
          if (state is ProfileSuccess) {
            final userData = state.user;
            return SingleChildScrollView(
              child: Column(
                children: [
                  ProfileHeader(userData: userData),
                  SizedBox(height: 16),
                  ProfileStatsCard(userData: userData),
                  SizedBox(height: 16),
                  ProfileBody(userData: userData),
                ],
              ),
            );
          }
          return const Center(child: Text("Profile"));
        },
      ),
    );
  }
}
