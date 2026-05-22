import 'package:flutter/material.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/core/shared/views/custom_bottom_navbar.dart';
import 'package:social_media_app/features/auth/views/auth_screen.dart';
import 'package:social_media_app/features/home/views/create_post_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.authScreen:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
        case AppRoutes.customBottomNavbar:
          return MaterialPageRoute(builder: (_) => const CustomBottomNavbar());
          case AppRoutes.createPost:
            return MaterialPageRoute(builder: (_) => const CreatePostScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(backgroundColor: Colors.amberAccent),
        );
    }
  }
}
