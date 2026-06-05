import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/features/profile/models/edit_profile_screen_args.dart';
import 'package:social_media_app/features/settings/cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: BlocProvider(
        create: (context) => SettingsCubit(),
        child: SettingsBody(),
      ),
    );
  }
}

class SettingsBody extends StatelessWidget {
  const SettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();
    return Column(
      children: [
        ListTile(
          onTap: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
            UserData? userData;
            try {
              userData = await CoreAuthServices().getCurrentUserData();
            } catch (e) {
              debugPrint('Error fetching user data: $e');
            } finally {
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop(); // remove loading dialog from root navigator
                if (userData != null) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.editProfile,
                    arguments: EditProfileScreenArgs(userData: userData),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to load profile data.')),
                  );
                }
              }
            }
          },
          leading: const Icon(Icons.person),
          title: const Text("Edit Profile"),
        ),
        BlocConsumer<SettingsCubit, SettingsState>(
          listenWhen: (previous, current) => current is SignOutSuccess || current is SignOutFailure,
          listener: (context, state) {
            if(state is SignOutSuccess){
              Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                AppRoutes.authScreen,
                (route) => false,
              );
            }
            else if(state is SignOutFailure){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          buildWhen: (previous, current) => current is SignOutLoading || current is SignOutSuccess || current is SignOutFailure,
          builder: (context, state) {
          if(state is SignOutLoading){
                return Center(child: CircularProgressIndicator());
            }
          return ListTile(
              onTap: () async{
               await settingsCubit.signOut();
              },
              leading: Icon(Icons.logout),
              title: Text("Logout"),
            );
          },
        ),
      ],
    );
  }
}
