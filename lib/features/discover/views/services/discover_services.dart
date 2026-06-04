import 'package:social_media_app/core/services/supabase_database_services.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiscoverServices {
  final supabase = Supabase.instance.client;
  final supabaseDatabaseServices = SupabaseDatabaseServices.instance;

  Future<List<UserData>> fetchAllUsers() async {
    try {
      return await supabaseDatabaseServices.fetchRows(
        table: 'users',
        primaryKey: 'id',
        builder: (data , id) => UserData.fromMap(data),
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
