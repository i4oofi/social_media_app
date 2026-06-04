part of 'settings_cubit.dart';

@immutable
sealed class SettingsState {}

final class SettingsInitial extends SettingsState {}

final class SignOutLoading extends SettingsState {}

final class SignOutSuccess extends SettingsState {}

final class SignOutFailure extends SettingsState {
  final String error;
  SignOutFailure({required this.error});
}

