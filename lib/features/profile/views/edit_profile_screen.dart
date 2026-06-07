import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/shared/widgets/user_avatar.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/features/auth/widgets/main_button.dart';
import 'package:social_media_app/features/profile/cubit/edit_profile_cubit/edit_profile_cubit.dart';

class EditProfileScreen extends StatelessWidget {
  final UserData userData;
  const EditProfileScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditProfileCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
        body: EditProfileBody(userData: userData),
      ),
    );
  }
}

class EditProfileBody extends StatefulWidget {
  final UserData userData;
  const EditProfileBody({super.key, required this.userData});

  @override
  State<EditProfileBody> createState() => _EditProfileBodyState();
}

class _EditProfileBodyState extends State<EditProfileBody> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userData.name;
    _titleController.text = widget.userData.title ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editProfileCubit = context.read<EditProfileCubit>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(height: 24),
            ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    UserAvatar(
                      radius: 50,
                      imageUrl: widget.userData.imageUrl,
                      name: widget.userData.name,
                    ),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.edit, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 36),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                SizedBox(height: 36),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BlocConsumer<EditProfileCubit, EditProfileState>(
                    listenWhen: (previous, current) =>
                        current is EditProfileSuccess ||
                        current is EditProfileFailure,
                    listener: (context, state) {
                      if (state is EditProfileSuccess) {
                        Navigator.pop(context);
                      }
                      if (state is EditProfileFailure) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.message)));
                      }
                    },
                    buildWhen: (previous, current) =>
                        current is EditProfileLoading ||
                        current is EditProfileSuccess ||
                        current is EditProfileFailure,
                    builder: (context, state) {
                      if (state is EditProfileLoading) {
                        return MainButton(isLoading: true);
                      }
                      return MainButton(
                        text: 'UPDATE',
                        onPressed: () async {
                          await editProfileCubit.editProfile(
                            _nameController.text,
                            _titleController.text,
                            widget.userData.imageUrl,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
