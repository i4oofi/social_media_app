import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_media_app/core/app_assets.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/auth/cubit/auth_cubit.dart';
import 'package:social_media_app/features/auth/widgets/main_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final AuthCubit authCubit = context.read<AuthCubit>();
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
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
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forget Password?',
                    style: TextStyle(color: AppColors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
        BlocConsumer<AuthCubit, AuthState>(
          bloc: authCubit,
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.red,
                ),
              );
            }
            if (state is AuthSuccess) {
              Navigator.pushNamed(context, AppRoutes.homeScreen);
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return MainButton(isLoading: true);
            }
            return MainButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await authCubit.signInWithEmail(
                    _emailController.text,
                    _passwordController.text,
                  );
                }
              },
              child: Text('Login'),
            );
          },
        ),
        SizedBox(height: 64),
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
              'Don\'t have an account?',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Sign Up',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
