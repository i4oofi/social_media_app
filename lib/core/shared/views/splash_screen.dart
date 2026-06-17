import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_media_app/core/app_assets.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/auth/cubit/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isAnimationComplete = false;
  AuthState? _resolvedAuthState;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isAnimationComplete = true;
        _checkAndNavigate();
      }
    });

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkState(context.read<AuthCubit>().state);
    });
  }

  void _checkState(AuthState state) {
    if (state is AuthSuccess ||
        state is AuthIncompleteProfile ||
        state is AuthInitial ||
        state is AuthFailure) {
      _resolvedAuthState = state;
      _checkAndNavigate();
    }
  }

  void _checkAndNavigate() {
    if (_isAnimationComplete && _resolvedAuthState != null) {
      final state = _resolvedAuthState!;
      if (state is AuthSuccess) {
        Navigator.pushReplacementNamed(context, AppRoutes.customBottomNavbar);
      } else if (state is AuthIncompleteProfile) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.completeProfileScreen,
        );
      } else if (state is AuthInitial || state is AuthFailure) {
        Navigator.pushReplacementNamed(context, AppRoutes.authScreen);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        _checkState(state);
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : AppColors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(AppAssets.appLogo, width: 220.w),
                ),
              ),
              SizedBox(height: 48.h),
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
