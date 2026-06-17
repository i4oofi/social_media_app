import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_media_app/core/app_assets.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/auth/cubit/auth_cubit.dart';
import 'package:social_media_app/features/auth/widgets/main_button.dart';
import 'package:social_media_app/core/shared/widgets/app_toast.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isObscure = true;
  bool _isConfirmObscure = true;

  InputDecoration _buildInputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.darkGrey),
      filled: true,
      fillColor: AppColors.babyBlue5,
      suffixIcon: suffixIcon,
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
    final AuthCubit authCubit = context.read<AuthCubit>();
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 4.h),
            TextFormField(
              controller: _emailController,
              decoration: _buildInputDecoration('Email'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _passwordController,
              decoration: _buildInputDecoration(
                'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                ),
              ),
              obscureText: _isObscure,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: _buildInputDecoration(
                'Confirm Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmObscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmObscure = !_isConfirmObscure;
                    });
                  },
                ),
              ),
              obscureText: _isConfirmObscure,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            SizedBox(height: 32.h),
            BlocConsumer<AuthCubit, AuthState>(
              listenWhen: (previous, current) =>
                  current is AuthLoading ||
                  current is AuthFailure ||
                  current is AuthSuccess ||
                  current is AuthSignUpSuccess ||
                  current is AuthIncompleteProfile,
              buildWhen: (previous, current) =>
                  current is AuthLoading ||
                  current is AuthFailure ||
                  current is AuthSuccess ||
                  current is AuthSignUpSuccess ||
                  current is AuthIncompleteProfile,
              listener: (context, state) {
                if (state is AuthFailure) {
                  debugPrint(state.message);
                  AppToast.showToast(
                    msg: state.message,
                    backgroundColor: AppColors.red,
                  );
                }
                if (state is AuthSuccess) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.customBottomNavbar,
                  );
                }
                if (state is AuthSignUpSuccess) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.emailVerificationScreen,
                  );
                }
                if (state is AuthIncompleteProfile) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.completeProfileScreen,
                  );
                }
              },
              builder: (context, state) {
                if (state is AuthLoading) {
                  return MainButton(isLoading: true);
                }
                return MainButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await authCubit.signUpWithEmail(
                        _emailController.text,
                        _passwordController.text,
                      );
                    }
                  },
                  child: Text('Join Now'),
                );
              },
            ),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: Divider(color: AppColors.black, thickness: 1.5),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text('Or signin with'),
                ),
                Expanded(
                  child: Divider(color: AppColors.black, thickness: 1.5),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => authCubit.signInWithGoogle(),
                  child: SvgPicture.asset(
                    AppAssets.googleIcon,
                    width: 50.w,
                    height: 50.h,
                  ),
                ),
                SizedBox(width: 32.w),
                InkWell(
                  onTap: () => authCubit.signInWithFacebook(),
                  child: SvgPicture.asset(
                    AppAssets.facebookIcon,
                    width: 50.w,
                    height: 50.h,
                  ),
                ),
                SizedBox(width: 32.w),
                InkWell(
                  onTap: () => authCubit.signInWithApple(),
                  child: SvgPicture.asset(
                    AppAssets.appleIcon,
                    width: 50.w,
                    height: 50.h,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    DefaultTabController.of(context).animateTo(0);
                  },
                  child: Text(
                    'Sign In',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
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
