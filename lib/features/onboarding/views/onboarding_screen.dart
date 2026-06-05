import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/app_assets.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:social_media_app/features/onboarding/widgets/onboarding_page_content.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingCubit(),
      child: const OnboardingBody(),
    );
  }
}

class OnboardingBody extends StatefulWidget {
  const OnboardingBody({super.key});

  @override
  State<OnboardingBody> createState() => _OnboardingBodyState();
}

class _OnboardingBodyState extends State<OnboardingBody> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: const Color(0xFFEDEAFF),
        body: Stack(
          children: [
            // 1. Translucent background overlay with white border as per Figma screen container 1
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(8.56),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.70),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    width: 8.56,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // 2. Rotated Ovals (Decorations from Figma properties)
            Positioned(
              left: -50,
              top: size.height * 0.15,
              child: Transform.rotate(
                angle: -3.14,
                child: Container(
                  width: 244.55,
                  height: 269.81,
                  decoration: const ShapeDecoration(
                    color: Color(0xFFD8F1FE),
                    shape: OvalBorder(),
                  ),
                ),
              ),
            ),
            Positioned(
              right: -50,
              bottom: size.height * 0.1,
              child: Transform.rotate(
                angle: -3.14,
                child: Container(
                  width: 244.55,
                  height: 269.81,
                  decoration: const ShapeDecoration(
                    color: Color(0xFFD8F1FE),
                    shape: OvalBorder(),
                  ),
                ),
              ),
            ),

            // 3. Skip Button (Top Right)
            Positioned(
              top: 48,
              right: 24,
              child: BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  final pageIndex = cubit.currentPage;
                  if (pageIndex < 2) {
                    return TextButton(
                      onPressed: () async {
                        await cubit.completeOnboarding();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.authScreen,
                            arguments: 0,
                          );
                        }
                      },
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // 4. PageView Content
            Positioned.fill(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => cubit.changePage(index),
                children: const [
                  OnboardingPageContent(
                    imagePath: AppAssets.onboarding1,
                    title: 'Welcome to Social Media App',
                    description:
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Erat vitae quis quam augue quam a.',
                  ),
                  OnboardingPageContent(
                    imagePath: AppAssets.onboarding2,
                    title: 'Find Friends & Get Inspiration',
                    description:
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Erat vitae quis quam augue quam a.',
                  ),
                  OnboardingPageContent(
                    imagePath: AppAssets.onboarding3,
                    title: 'Share Your Story With The World',
                    description:
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Erat vitae quis quam augue quam a.',
                  ),
                ],
              ),
            ),

            // 5. Dynamic bottom controls
            Positioned(
              bottom: 48,
              left: 24,
              right: 24,
              child: BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  final pageIndex = cubit.currentPage;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final isActive = index == pageIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 27 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF007AFF)
                                  : const Color(0xFFC4C4C4),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),

                      // Navigation buttons
                      if (pageIndex == 0) ...[
                        // Screen 1: Simple "Next" button
                        SizedBox(
                          width: 320,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007AFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Next',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Screen 2 & 3: "Join Now" and "Sign in" buttons
                        SizedBox(
                          width: 320,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              await cubit.completeOnboarding();
                              if (context.mounted) {
                                // Go to Sign Up
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.authScreen,
                                  arguments: 1, // index 1 is SignUp
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007AFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Join Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () async {
                            await cubit.completeOnboarding();
                            if (context.mounted) {
                              // Go to Sign In
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.authScreen,
                                arguments: 0, // index 0 is SignIn
                              );
                            }
                          },
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              color: Color(0xFF5096F1),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.16,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}
