import 'package:flutter/material.dart';
import 'package:social_media_app/core/app_routes.dart';
import 'package:social_media_app/features/auth/views/auth_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.authScreen:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(backgroundColor: Colors.amberAccent),
        );
    }
  }
}
