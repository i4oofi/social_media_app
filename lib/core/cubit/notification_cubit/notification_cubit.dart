import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/core/services/notification_services.dart';
import 'package:social_media_app/core/models/notification_model.dart';
import 'package:social_media_app/core/di/service_locator.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());
  final notificationServices = sl<NotificationServices>();
  final coreAuthServices = sl<CoreAuthServices>();

  Future<void> fetchNotifications() async {
    try {
      emit(NotificationsLoading());
      final currentUser = await coreAuthServices.getCurrentUserData();
      if (currentUser == null) {
        emit(NotificationsLoaded(notifications: const []));
        return;
      }
      final rawNotifications = await notificationServices.fetchNotifications(currentUser.id);
      
      List<NotificationModel> notifications = [];
      for (var notification in rawNotifications) {
        final userData = await coreAuthServices.getUserData(notification.senderId);
        if (userData != null) {
          notification = notification.copyWith(
            senderName: userData.name,
            senderImageUrl: userData.imageUrl,
          );
        }
        notifications.add(notification);
      }
      
      emit(NotificationsLoaded(notifications: notifications));
    } catch (e) {
      emit(NotificationsError(error: e.toString()));
    }
  }

  Future<void> sendNotification({
    required String receiverId,
    required String type,
    String? postId,
  }) async {
    try {
      final currentUser = await coreAuthServices.getCurrentUserData();
      if (currentUser == null) return;
      
      final notification = NotificationModel(
        id: '',
        createdAt: '',
        receiverId: receiverId,
        senderId: currentUser.id,
        type: type,
        postId: postId,
        isRead: false,
      );
      
      await notificationServices.createNotification(notification);
    } catch (_) {}
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await notificationServices.markAsRead(notificationId);
      if (state is NotificationsLoaded) {
        final currentNotifications = (state as NotificationsLoaded).notifications;
        final updated = currentNotifications.map((n) {
          if (n.id == notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();
        emit(NotificationsLoaded(notifications: updated));
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      final currentUser = await coreAuthServices.getCurrentUserData();
      if (currentUser == null) return;
      await notificationServices.markAllAsRead(currentUser.id);
      
      if (state is NotificationsLoaded) {
        final currentNotifications = (state as NotificationsLoaded).notifications;
        final updated = currentNotifications.map((n) => n.copyWith(isRead: true)).toList();
        emit(NotificationsLoaded(notifications: updated));
      }
    } catch (_) {}
  }
}
