import 'package:social_media_app/core/services/supabase_database_services.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiscoverServices {
  final supabase = Supabase.instance.client;
  final supabaseDatabaseServices = SupabaseDatabaseServices.instance;

  Future<List<UserData>> fetchAllUsers() async {
    try {
      final currentUserId = supabase.auth.currentUser?.id;
      return await supabaseDatabaseServices.fetchRows(
        table: 'users',
        primaryKey: 'id',
        builder: (data , id) => UserData.fromMap(data),
        filter: currentUserId != null
            ? (query) => query.neq('id', currentUserId)
            : null,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
