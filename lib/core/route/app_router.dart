import 'package:flutter/material.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/features/auth/views/auth_screen.dart';
import 'package:social_media_app/features/home/home_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.authScreen:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
        case AppRoutes.homeScreen:
          return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(backgroundColor: Colors.amberAccent),
        );
    }
  }
}
