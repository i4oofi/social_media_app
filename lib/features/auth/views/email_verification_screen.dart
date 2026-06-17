import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/auth/cubit/auth_cubit.dart';
import 'package:social_media_app/features/auth/widgets/main_button.dart';
import 'package:social_media_app/core/shared/widgets/app_toast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // Listen for deep links automatically using Supabase auth listener
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _checkVerification();
      }
    });

    // Optionally check periodically
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkVerification(silent: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification({bool silent = false}) async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final authCubit = context.read<AuthCubit>();
      final isVerified = await authCubit.authServices.checkEmailVerified();
      if (isVerified) {
        _timer?.cancel();
        if (mounted) {
          // If verified, proceed to complete profile
          Navigator.pushReplacementNamed(context, AppRoutes.completeProfileScreen);
        }
      } else {
        if (!silent && mounted) {
          AppToast.showToast(msg: 'Email not verified yet', backgroundColor: AppColors.red);
        }
      }
    } catch (e) {
      if (!silent && mounted) {
        AppToast.showToast(msg: e.toString(), backgroundColor: AppColors.red);
      }
    } finally {
      _isChecking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Email'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mark_email_unread_outlined,
              size: 100.h,
              color: AppColors.primaryColor,
            ),
            SizedBox(height: 32.h),
            Text(
              'Check your email',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              'We have sent a verification link to your email address. Please click the link to verify your account.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.darkGrey,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48.h),
            MainButton(
              onPressed: () => _checkVerification(silent: false),
              child: Text('I have verified'),
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () async {
                try {
                  await context.read<AuthCubit>().authServices.resendVerificationEmail();
                  if (context.mounted) {
                    AppToast.showToast(msg: 'Verification email resent!', backgroundColor: Colors.green);
                  }
                } catch (e) {
                  if (context.mounted) {
                    AppToast.showToast(msg: e.toString(), backgroundColor: AppColors.red);
                  }
                }
              },
              child: Text(
                'Resend Email',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
