import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
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
    with TickerProviderStateMixin {
  // ── Phase 1: Icon entrance ──────────────────────────────────────────────
  late AnimationController _iconController;
  late Animation<double> _iconFade;
  late Animation<double> _iconScale;
  // ── Phase 2: Wordmark entrance ──────────────────────────────────────────
  late AnimationController _wordmarkController;
  late Animation<double> _wordmarkFade;
  late Animation<Offset> _wordmarkSlide;
  // ── Phase 3: Tagline entrance ───────────────────────────────────────────
  late AnimationController _taglineController;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;
  // ── Phase 4: Animated dots ──────────────────────────────────────────────
  late AnimationController _dotsController;
  // ── Glow pulse behind icon ───────────────────────────────────────────────
  late AnimationController _glowController;
  late Animation<double> _glowScale;
  late Animation<double> _glowOpacity;
  bool _isAnimationComplete = false;
  AuthState? _resolvedAuthState;
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkState(context.read<AuthCubit>().state);
    });
  }

  void _setupAnimations() {
    // ── Glow pulse (runs continuously) ─────────────────────────────────────
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glowScale = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowOpacity = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    // ── Icon: scale + fade in ───────────────────────────────────────────────
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _iconFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _iconController, curve: Curves.easeIn));
    _iconScale = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    // ── Wordmark: slide + fade ──────────────────────────────────────────────
    _wordmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _wordmarkFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _wordmarkController, curve: Curves.easeOut),
    );
    _wordmarkSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _wordmarkController,
            curve: Curves.easeOutCubic,
          ),
        );
    // ── Tagline: slide + fade ───────────────────────────────────────────────
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _taglineController,
            curve: Curves.easeOutCubic,
          ),
        );
    // ── Bouncing dots (loops) ──────────────────────────────────────────────
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  Future<void> _startSequence() async {
    // Small initial delay so native splash has time to fade out
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    // Phase 1 — icon
    await _iconController.forward();
    if (!mounted) return;
    // Phase 2 — wordmark (slight overlap with icon settling)
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    await _wordmarkController.forward();
    if (!mounted) return;
    // Phase 3 — tagline
    await Future.delayed(const Duration(milliseconds: 60));
    if (!mounted) return;
    await _taglineController.forward();
    if (!mounted) return;
    // Phase 4 — dots start looping
    _dotsController.repeat();
    // Hold briefly so everything is visible, then mark complete
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _isAnimationComplete = true;
    _checkAndNavigate();
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
    _glowController.dispose();
    _iconController.dispose();
    _wordmarkController.dispose();
    _taglineController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : AppColors.white;
    final textColor = isDark ? AppColors.white : AppColors.black;
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) => _checkState(state),
      child: Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Icon + Glow ────────────────────────────────────────────────
              AnimatedBuilder(
                animation: Listenable.merge([_iconController, _glowController]),
                builder: (context, _) {
                  return FadeTransition(
                    opacity: _iconFade,
                    child: ScaleTransition(
                      scale: _iconScale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow ring
                          Transform.scale(
                            scale: _glowScale.value,
                            child: Container(
                              width: 88.w,
                              height: 88.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.primaryColor.withValues(
                                      alpha: _glowOpacity.value,
                                    ),
                                    AppColors.primaryColor.withValues(
                                      alpha: 0.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Icon
                          SvgPicture.asset(
                            AppAssets.appLogoIcon,
                            width: 64.w,
                            height: 64.w,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20.h),
              // ── Full wordmark (text + icon combined) ──────────────────────
              SlideTransition(
                position: _wordmarkSlide,
                child: FadeTransition(
                  opacity: _wordmarkFade,
                  child: SvgPicture.asset(AppAssets.appLogo, width: 200.w),
                ),
              ),
              SizedBox(height: 12.h),
              // ── Tagline ────────────────────────────────────────────────────
              SlideTransition(
                position: _taglineSlide,
                child: FadeTransition(
                  opacity: _taglineFade,
                  child: Text(
                    'Connect. Share. Inspire.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: textColor.withValues(alpha: 0.45),
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 64.h),
              // ── Animated dots loader ───────────────────────────────────────
              FadeTransition(
                opacity: _taglineFade,
                child: _BouncingDots(controller: _dotsController),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bouncing dots widget
// ─────────────────────────────────────────────────────────────────────────────
class _BouncingDots extends StatelessWidget {
  const _BouncingDots({required this.controller});
  final AnimationController controller;
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Stagger each dot by 120ms (0.12 fraction of 1000ms cycle)
            const stagger = 0.28;
            final offset = i * stagger;
            final t = ((controller.value - offset) % 1.0 + 1.0) % 1.0;
            // Sine wave: 0 → up → 0
            final dy = math.sin(t * math.pi) * -8.0;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Transform.translate(
                offset: Offset(0, dy),
                child: Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(
                      alpha: 0.4 + 0.6 * math.sin(t * math.pi).clamp(0, 1),
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
