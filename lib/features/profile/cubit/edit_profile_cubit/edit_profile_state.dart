part of 'edit_profile_cubit.dart';

@immutable
sealed class EditProfileState {}

final class EditProfileInitial extends EditProfileState {}

final class EditProfileLoading extends EditProfileState {}

final class EditProfileSuccess extends EditProfileState {}

final class EditProfileFailure extends EditProfileState {
  final String message;
  EditProfileFailure({required this.message});
}

/// Emitted while a profile image is being picked (for UI preview).
final class EditProfileImagePicked extends EditProfileState {
  final String imagePath;
  EditProfileImagePicked({required this.imagePath});
}

/// Emitted while a cover image is being picked (for UI preview).
final class EditProfileCoverPicked extends EditProfileState {
  final String coverPath;
  EditProfileCoverPicked({required this.coverPath});
}
