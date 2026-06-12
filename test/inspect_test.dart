import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:social_media_app/core/app_constants.dart';

void main() {
  test('inspect notifications table', () async {
    final client = SupabaseClient(
      AppConstants.supabaseUrl,
      AppConstants.supabaseAnonKey,
    );
    try {
      final res = await client.from('notifications').select().limit(1);
      print('Notifications table exists. Sample data: $res');
    } catch (e) {
      print('Error querying notifications: $e');
    }
  });
}

