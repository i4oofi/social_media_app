import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_app/core/app_constants.dart';
import 'package:social_media_app/core/cubit/posts_cubit/posts_cubit.dart';
import 'package:social_media_app/core/di/service_locator.dart';
import 'package:social_media_app/core/route/app_router.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/core/theme/app_theme.dart';
import 'package:social_media_app/features/auth/cubit/auth_cubit.dart' as auth;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:social_media_app/core/cubit/theme_cubit/theme_cubit.dart';
import 'package:social_media_app/core/cubit/notification_cubit/notification_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:social_media_app/firebase_options.dart';
import 'package:social_media_app/core/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  setupLocator();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await PushNotificationService.init();

  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted =
      prefs.getBool('onboarding_completed') ?? false;

  runApp(MyApp(onboardingCompleted: onboardingCompleted));
}

class MyApp extends StatelessWidget {
  final bool onboardingCompleted;
  const MyApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => auth.AuthCubit()..checkUserAuth()),
        BlocProvider(create: (context) => PostsCubit()),
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => NotificationCubit()),
      ],
      child: Builder(
        builder: (context) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return BlocBuilder<auth.AuthCubit, auth.AuthState>(
                bloc: BlocProvider.of<auth.AuthCubit>(context),
                buildWhen: (previous, current) => current is auth.AuthSuccess,
                builder: (context, authState) {
                  return ScreenUtilInit(
                    designSize: const Size(375, 812),
                    minTextAdapt: true,
                    splitScreenMode: true,
                    builder: (context, child) {
                      return MaterialApp(
                        debugShowCheckedModeBanner: false,
                        title: AppConstants.appName,
                        theme: AppTheme.lightThem,
                        darkTheme: AppTheme.darkTheme,
                        themeMode: themeMode,
                        onGenerateRoute: AppRouter.onGenerateRoute,
                        initialRoute: !onboardingCompleted
                            ? AppRoutes.onboardingScreen
                            : AppRoutes.splashScreen,
                        builder: (context, widget) {
                          // Ensure ScreenUtil is initialized for nested widgets
                          return child ?? widget ?? const SizedBox.shrink();
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
