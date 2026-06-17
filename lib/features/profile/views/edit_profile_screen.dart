import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/shared/widgets/user_avatar.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/features/auth/widgets/main_button.dart';
import 'package:social_media_app/features/profile/cubit/edit_profile_cubit/edit_profile_cubit.dart';
import 'package:social_media_app/core/shared/widgets/app_toast.dart';
import 'package:social_media_app/core/theme/app_colors.dart';

class EditProfileScreen extends StatelessWidget {
  final UserData userData;
  const EditProfileScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditProfileCubit(),
      child: Scaffold(
        appBar: AppBar(title: Text('Edit Profile'), centerTitle: true),
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
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  // Local preview paths (null = not yet picked, use network URL)
  String? _localProfileImagePath;
  String? _localCoverImagePath;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userData.name;
    _userNameController.text = widget.userData.userName ?? '';
    _titleController.text = widget.userData.title ?? '';
    _dobController.text = widget.userData.dob ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    _titleController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final editProfileCubit = context.read<EditProfileCubit>();

    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listenWhen: (previous, current) =>
          current is EditProfileSuccess ||
          current is EditProfileFailure ||
          current is EditProfileImagePicked ||
          current is EditProfileCoverPicked,
      listener: (context, state) {
        if (state is EditProfileSuccess) {
          AppToast.showToast(
            msg: 'Profile updated successfully!',
            backgroundColor: Colors.green,
          );
          Navigator.pop(context);
        }
        if (state is EditProfileFailure) {
          AppToast.showToast(
            msg: state.message,
            backgroundColor: AppColors.red,
          );
        }
        if (state is EditProfileImagePicked) {
          setState(() => _localProfileImagePath = state.imagePath);
        }
        if (state is EditProfileCoverPicked) {
          setState(() => _localCoverImagePath = state.coverPath);
        }
      },
      builder: (context, state) {
        final isLoading = state is EditProfileLoading;

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Cover Photo Section ──────────────────────────────────
                _CoverPhotoSection(
                  localCoverPath: _localCoverImagePath,
                  networkCoverUrl: widget.userData.coverUrl,
                  onTap: () => editProfileCubit.pickCoverImage(),
                ),

                // ── Profile Avatar (overlapping cover) ──────────────────
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: _ProfileAvatarSection(
                    localProfilePath: _localProfileImagePath,
                    networkImageUrl: widget.userData.imageUrl,
                    name: widget.userData.name,
                    onTap: () => editProfileCubit.pickProfileImage(),
                  ),
                ),

                // ── Form Fields ──────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 4.h),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Name',
                        icon: Icons.person_outline,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _userNameController,
                        label: 'Username',
                        icon: Icons.alternate_email,
                      ),
                      SizedBox(height: 16.h),
                      TextField(
                        controller: _dobController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          prefixIcon: Icon(Icons.cake_outlined, color: AppColors.primaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: AppColors.primaryColor, width: 2.w),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _titleController,
                        label: 'Title / Bio',
                        icon: Icons.short_text,
                      ),
                      SizedBox(height: 32.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: MainButton(
                          isLoading: isLoading,
                          text: isLoading ? null : 'UPDATE PROFILE',
                          onPressed: isLoading
                              ? null
                              : () async {
                                  await editProfileCubit.editProfile(
                                    name: _nameController.text,
                                    userName: _userNameController.text,
                                    dob: _dobController.text,
                                    title: _titleController.text,
                                    existingImageUrl: widget.userData.imageUrl,
                                    existingCoverUrl: widget.userData.coverUrl,
                                  );
                                },
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2.w),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cover Photo Widget
// ─────────────────────────────────────────────────────────────────────────────
class _CoverPhotoSection extends StatelessWidget {
  final String? localCoverPath;
  final String? networkCoverUrl;
  final VoidCallback onTap;

  const _CoverPhotoSection({
    required this.localCoverPath,
    required this.networkCoverUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = localCoverPath != null || networkCoverUrl != null;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Cover image / placeholder
          Container(
            width: double.infinity,
            height: 180.h,
            decoration: BoxDecoration(
              color: AppColors.babyBlue15,
              image: localCoverPath != null
                  ? DecorationImage(
                      image: FileImage(File(localCoverPath!)),
                      fit: BoxFit.cover,
                    )
                  : (networkCoverUrl != null
                      ? DecorationImage(
                          image: NetworkImage(networkCoverUrl!),
                          fit: BoxFit.cover,
                        )
                      : null),
            ),
            child: hasImage
                ? null
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40.h,
                        color: AppColors.primaryColor.withValues(alpha: 0.7),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Add Cover Photo',
                        style: TextStyle(
                          color: AppColors.primaryColor.withValues(alpha: 0.7),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),

          // Edit overlay
          Positioned.fill(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: hasImage
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      )
                    : null,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white, size: 14.h),
                    SizedBox(width: 4.w),
                    Text(
                      'Edit Cover',
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Avatar Widget
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileAvatarSection extends StatelessWidget {
  final String? localProfilePath;
  final String? networkImageUrl;
  final String name;
  final VoidCallback onTap;

  const _ProfileAvatarSection({
    required this.localProfilePath,
    required this.networkImageUrl,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Avatar ring
          Container(
            width: 108.w,
            height: 108.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: localProfilePath != null
                  ? Image.file(
                      File(localProfilePath!),
                      fit: BoxFit.cover,
                      width: 100.w,
                      height: 100.h,
                    )
                  : UserAvatar(
                      radius: 50.r,
                      imageUrl: networkImageUrl,
                      name: name,
                    ),
            ),
          ),

          // Dark edit overlay
          Container(
            width: 108.w,
            height: 108.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black38,
            ),
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 28.h,
            ),
          ),
        ],
      ),
    );
  }
}
