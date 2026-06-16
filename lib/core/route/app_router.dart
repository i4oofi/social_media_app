import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/route/app_routes.dart';
import 'package:social_media_app/core/shared/views/custom_bottom_navbar.dart';
import 'package:social_media_app/features/auth/views/auth_screen.dart';
import 'package:social_media_app/features/auth/views/complete_profile_screen.dart';
import 'package:social_media_app/features/auth/views/email_verification_screen.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';
import 'package:social_media_app/features/home/views/create_post_screen.dart';
import 'package:social_media_app/features/onboarding/views/onboarding_screen.dart';
import 'package:social_media_app/features/profile/models/edit_profile_screen_args.dart';
import 'package:social_media_app/features/profile/views/edit_profile_screen.dart';
import 'package:social_media_app/features/settings/views/setting_screen.dart';
import 'package:social_media_app/features/home/views/create_story_screen.dart';
import 'package:social_media_app/core/models/chat_model.dart';
import 'package:social_media_app/features/chat/views/inbox_screen.dart';
import 'package:social_media_app/features/chat/views/chat_room_screen.dart';

import 'package:social_media_app/features/home/views/post_detail_screen.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/features/settings/views/saved_posts_screen.dart';
import 'package:social_media_app/features/home/views/notifications_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.onboardingScreen:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case AppRoutes.authScreen:
        final initialIndex = settings.arguments as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => AuthScreen(initialIndex: initialIndex),
        );
      case AppRoutes.completeProfileScreen:
        return MaterialPageRoute(builder: (_) => const CompleteProfileScreen());
      case AppRoutes.emailVerificationScreen:
        return MaterialPageRoute(builder: (_) => const EmailVerificationScreen());
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
        final args = settings.arguments as EditProfileScreenArgs;
        return MaterialPageRoute(
          builder: (_) => EditProfileScreen(
            userData: args.userData,
          ),
        );
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.inboxScreen:
        return MaterialPageRoute(builder: (_) => const InboxScreen());
      case AppRoutes.chatRoomScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        final chat = args?['chat'] as ChatModel?;
        final otherUserId = args?['otherUserId'] as String?;
        return MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            chat: chat,
            otherUserId: otherUserId,
          ),
        );
      case AppRoutes.createStory:
        final homeCubit = settings.arguments as HomeCubit;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: homeCubit,
            child: const CreateStoryScreen(),
          ),
        );
      case AppRoutes.postDetailScreen:
        final post = settings.arguments as PostModel;
        return MaterialPageRoute(
          builder: (_) => PostDetailScreen(post: post),
        );
      case AppRoutes.savedPosts:
        return MaterialPageRoute(builder: (_) => const SavedPostsScreen());
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(backgroundColor: Colors.amberAccent),
        );
    }
  }
}
