import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/auth/cubit/auth_cubit.dart';
import 'package:social_media_app/features/auth/widgets/main_button.dart';
import 'package:social_media_app/core/shared/widgets/app_toast.dart';
import 'package:social_media_app/core/services/file_picker_services.dart';
import 'package:social_media_app/core/di/service_locator.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  File? _profileImage;
  File? _coverImage;
  bool _isCheckingUsername = false;
  bool _isUsernameUnique = true;
  String _usernameError = '';

  final filePickerServices = sl<FilePickerServices>();

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final xFile = await filePickerServices.pickImage();
    if (xFile != null) {
      setState(() {
        _profileImage = File(xFile.path);
      });
    }
  }

  Future<void> _pickCoverImage() async {
    final xFile = await filePickerServices.pickImage();
    if (xFile != null) {
      setState(() {
        _coverImage = File(xFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // default 18 years ago
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

  Future<void> _checkUsername(String value) async {
    if (value.isEmpty) {
      setState(() {
        _usernameError = '';
      });
      return;
    }
    
    setState(() {
      _isCheckingUsername = true;
      _usernameError = '';
    });

    final isUnique = await context.read<AuthCubit>().authServices.checkUsernameUnique(value);
    
    setState(() {
      _isCheckingUsername = false;
      _isUsernameUnique = isUnique;
      if (!isUnique) {
        _usernameError = 'Username is already taken';
      }
    });
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.darkGrey),
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark 
          ? AppColors.darkGrey.withOpacity(0.2) 
          : AppColors.babyBlue5,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.babyBlue15, width: 1.w),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.red, width: 1.w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            AppToast.showToast(msg: state.message, backgroundColor: AppColors.red);
          } else if (state is AuthSuccess) {
            Navigator.pushReplacementNamed(context, AppRoutes.customBottomNavbar);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(24.0.w),
              children: [
                // Cover Image
                GestureDetector(
                  onTap: _pickCoverImage,
                  child: Container(
                    height: 150.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark 
                          ? AppColors.darkGrey 
                          : AppColors.babyBlue15,
                      borderRadius: BorderRadius.circular(16.r),
                      image: _coverImage != null
                          ? DecorationImage(
                              image: FileImage(_coverImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _coverImage == null
                        ? Center(
                            child: Icon(Icons.camera_alt, color: AppColors.white, size: 40.h),
                          )
                        : null,
                  ),
                ),
                SizedBox(height: 16.h),
                
                // Profile Image (overlapping cover)
                Center(
                  child: GestureDetector(
                    onTap: _pickProfileImage,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50.r,
                          backgroundColor: theme.brightness == Brightness.dark 
                              ? AppColors.darkGrey 
                              : AppColors.babyBlue15,
                          backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                          child: _profileImage == null
                              ? Icon(Icons.person, size: 50.h, color: AppColors.white)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.edit, color: AppColors.white, size: 20.h),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32.h),

                // Form Fields
                TextFormField(
                  controller: _fullNameController,
                  decoration: _buildInputDecoration('Full Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16.h),

                TextFormField(
                  controller: _usernameController,
                  decoration: _buildInputDecoration('Username').copyWith(
                    errorText: _usernameError.isNotEmpty ? _usernameError : null,
                    suffixIcon: _isCheckingUsername 
                        ? Padding(
                            padding: EdgeInsets.all(12.0.w),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                  onChanged: (val) {
                    _checkUsername(val);
                  },
                  validator: (value) {
                    if (value!.isEmpty) return 'Required';
                    if (!_isUsernameUnique) return 'Username taken';
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: _buildInputDecoration('Date of Birth').copyWith(
                    suffixIcon: Icon(Icons.calendar_today, color: AppColors.primaryColor),
                  ),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16.h),

                TextFormField(
                  controller: _bioController,
                  decoration: _buildInputDecoration('Bio (Optional)'),
                  maxLines: 3,
                ),
                SizedBox(height: 40.h),

                MainButton(
                  isLoading: isLoading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_profileImage == null) {
                        AppToast.showToast(msg: 'Profile image is required', backgroundColor: AppColors.red);
                        return;
                      }
                      if (!_isUsernameUnique) {
                        return;
                      }
                      context.read<AuthCubit>().completeProfile(
                        name: _fullNameController.text,
                        userName: _usernameController.text,
                        dob: _dobController.text,
                        title: _bioController.text,
                        profileImageFile: _profileImage,
                        coverImageFile: _coverImage,
                      );
                    }
                  },
                  child: Text('Complete Profile'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
