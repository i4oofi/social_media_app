import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/core/shared/views/custom_bottom_navbar.dart';
import 'package:social_media_app/features/auth/views/auth_screen.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';
import 'package:social_media_app/features/home/views/create_post_screen.dart';
import 'package:social_media_app/features/profile/views/edit_profile_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.authScreen:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case AppRoutes.customBottomNavbar:
        return MaterialPageRoute(builder: (_) => const CustomBottomNavbar());
      case AppRoutes.createPost:
        final homeCubit = settings.arguments as HomeCubit;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: homeCubit,
            child: const CreatePostScreen(),
          ),
        );
      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(backgroundColor: Colors.amberAccent),
        );
    }
  }
}
