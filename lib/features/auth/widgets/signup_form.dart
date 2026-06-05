import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_media_app/core/app_assets.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/auth/cubit/auth_cubit.dart';
import 'package:social_media_app/features/auth/widgets/main_button.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final AuthCubit authCubit = context.read<AuthCubit>();
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
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
            SizedBox(height: 32),
            BlocConsumer<AuthCubit, AuthState>(
              listenWhen: (previous, current) =>
                  current is AuthLoading ||
                  current is AuthFailure ||
                  current is AuthSuccess,
              buildWhen: (previous, current) =>
                  current is AuthLoading ||
                  current is AuthFailure ||
                  current is AuthSuccess,
              listener: (context, state) {
                if (state is AuthFailure) {
                  debugPrint(state.message);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.red,
                    ),
                  );
                }
                if (state is AuthSuccess) {
                  Navigator.pushReplacementNamed(context, AppRoutes.customBottomNavbar);
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
                        _usernameController.text,
                      );
                    }
                  },
                  child: Text('Join Now'),
                );
              },
            ),
            SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.black, thickness: 1.5)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Or signin with'),
                ),
                Expanded(child: Divider(color: AppColors.black, thickness: 1.5)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(AppAssets.googleIcon, width: 50, height: 50),
                SizedBox(width: 32),
                SvgPicture.asset(AppAssets.facebookIcon, width: 50, height: 50),
                SizedBox(width: 32),
                SvgPicture.asset(AppAssets.appleIcon, width: 50, height: 50),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextButton(
                  onPressed: () {},
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
