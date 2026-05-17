import 'package:flutter/material.dart';
import 'package:social_media_app/core/app_constants.dart';
import 'package:social_media_app/core/app_router.dart';
import 'package:social_media_app/core/app_routes.dart';
import 'package:social_media_app/core/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.lightThem,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRoutes.authScreen,
    );
  }
}
