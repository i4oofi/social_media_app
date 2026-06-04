import 'package:social_media_app/core/services/supabase_database_services.dart';
import 'package:social_media_app/core/theme/app_tables_names.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoreAuthServices {
  final supabaseDataBaseServices = SupabaseDatabaseServices.instance;
  final supabase = Supabase.instance.client;
  Future<UserData?> getCurrentUserData() async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        return null;
      }
      final currentUserId = currentUser.id;

      // Try fetching the user profile data
      UserData? userData = await supabaseDataBaseServices.fetchRowOptional(
        table: AppTablesNames.users,
        primaryKey: 'id',
        id: currentUserId,
        builder: (data, id) => UserData.fromMap(data),
      );

      // Self-healing: If the authenticated user has no corresponding profile row, provision it.
      if (userData == null) {
        final name = currentUser.userMetadata?['name'] as String? ??
            currentUser.email?.split('@').first ??
            'User';
        final email = currentUser.email ?? '';

        // Check if a row with the same email already exists (e.g., from a previous incomplete signup)
        final existingByEmail = await supabaseDataBaseServices.fetchRowOptional(
          table: AppTablesNames.users,
          primaryKey: 'email',
          id: email,
          builder: (data, id) => UserData.fromMap(data),
        );

        if (existingByEmail != null) {
          // A row with this email exists but has a different ID. Update its ID to the correct one.
          await supabaseDataBaseServices.updateRow(
            table: AppTablesNames.users,
            values: {'id': currentUserId},
            column: 'email',
            value: email,
          );
          userData = existingByEmail.copyWith(id: currentUserId);
        } else {
          // No row exists with this email either. Insert a brand new row.
          userData = UserData(
            id: currentUserId,
            name: name,
            email: email,
          );
          await supabaseDataBaseServices.insertRow(
            table: AppTablesNames.users,
            values: userData.toMap(),
          );
        }
      }

      return userData;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserData?> getUserData(String userId) async {
    try {
      return await supabaseDataBaseServices.fetchRowOptional<UserData>(
        table: AppTablesNames.users,
        primaryKey: 'id',
        id: userId,
        builder: (data, id) => UserData.fromMap(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
