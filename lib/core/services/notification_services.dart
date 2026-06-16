import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:social_media_app/core/services/supabase_database_services.dart';
import 'package:social_media_app/core/theme/app_tables_names.dart';
import 'package:social_media_app/core/models/notification_model.dart';

class NotificationServices {
  final supabaseServices = SupabaseDatabaseServices.instance;
  SupabaseClient get _db => Supabase.instance.client;

  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    try {
      final rows = await _db
          .from(AppTablesNames.notifications)
          .select()
          .eq('receiver_id', userId)
          .order('created_at', ascending: false);
      return (rows as List<dynamic>)
          .map((e) => NotificationModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (dbError) {
      final errorStr = dbError.toString();
      if (errorStr.contains('PGRST205') ||
          errorStr.contains('Could not find') ||
          errorStr.contains('does not exist')) {
        return [];
      }
      rethrow;
    }
  }

  Future<void> createNotification(NotificationModel notification) async {
    // Prevent self-notifications
    if (notification.senderId == notification.receiverId) return;
    try {
      await supabaseServices.insertRow(
        table: AppTablesNames.notifications,
        values: notification.toMap(),
      );
    } catch (dbError) {
      final errorStr = dbError.toString();
      if (errorStr.contains('PGRST205') ||
          errorStr.contains('Could not find') ||
          errorStr.contains('does not exist')) {
        return;
      }
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await supabaseServices.updateRow(
        table: AppTablesNames.notifications,
        values: {'is_read': true},
        column: 'id',
        value: notificationId,
      );
    } catch (_) {}
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _db
          .from(AppTablesNames.notifications)
          .update({'is_read': true})
          .eq('receiver_id', userId);
    } catch (_) {}
  }
}
