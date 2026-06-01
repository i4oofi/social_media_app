part of 'private_profile_cubit.dart';

@immutable
sealed class PrivateProfileState {}

final class ProfileInitial extends PrivateProfileState {}

final class ProfileLoading extends PrivateProfileState {}

final class ProfileSuccess extends PrivateProfileState {
  final UserData user;
  ProfileSuccess(this.user);
}

final class ProfileFailure extends PrivateProfileState {
  final String message;
  ProfileFailure(this.message);
}
