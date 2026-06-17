import 'package:get_it/get_it.dart';

// Services
import 'package:social_media_app/core/services/post_services.dart';
import 'package:social_media_app/core/services/supabase_database_services.dart';
import 'package:social_media_app/core/services/file_picker_services.dart';
import 'package:social_media_app/core/services/notification_services.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/features/home/services/home_services.dart';
import 'package:social_media_app/features/profile/services/profile_services.dart';
import 'package:social_media_app/features/auth/services/auth_services.dart';
import 'package:social_media_app/features/chat/services/chat_services.dart';
import 'package:social_media_app/features/discover/views/services/discover_services.dart';

final sl = GetIt.instance;

void setupLocator() {
  // Core Services
  sl.registerLazySingleton<SupabaseDatabaseServices>(
    () => SupabaseDatabaseServices.instance,
  );
  sl.registerLazySingleton<CoreAuthServices>(() => CoreAuthServices());
  sl.registerLazySingleton<PostServices>(() => PostServices());
  sl.registerLazySingleton<FilePickerServices>(() => FilePickerServices());
  sl.registerLazySingleton<NotificationServices>(() => NotificationServices());

  // Feature Services
  sl.registerLazySingleton<HomeServices>(() => HomeServices());
  sl.registerLazySingleton<ProfileServices>(() => ProfileServices());
  sl.registerLazySingleton<AuthServices>(() => AuthServices());
  sl.registerLazySingleton<ChatServices>(() => ChatServices());
  sl.registerLazySingleton<DiscoverServices>(() => DiscoverServices());
}
