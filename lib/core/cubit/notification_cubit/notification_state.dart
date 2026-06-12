part of 'notification_cubit.dart';

@immutable
sealed class NotificationState {}

final class NotificationInitial extends NotificationState {}

final class NotificationsLoading extends NotificationState {}

final class NotificationsLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  NotificationsLoaded({required this.notifications});
}

final class NotificationsError extends NotificationState {
  final String error;
  NotificationsError({required this.error});
}
