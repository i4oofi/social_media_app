import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/core/services/file_picker_services.dart';
import 'package:social_media_app/features/profile/services/profile_services.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit() : super(EditProfileInitial());

  final profileServices = ProfileServices();
  final coreAuthServices = CoreAuthServices();
  final filePickerServices = FilePickerServices();

  File? _profileImageFile;
  File? _coverImageFile;

  File? get profileImageFile => _profileImageFile;
  File? get coverImageFile => _coverImageFile;

  /// Opens the gallery to let the user pick a new profile picture.
  Future<void> pickProfileImage() async {
    try {
      final xFile = await filePickerServices.pickImage();
      if (xFile != null) {
        _profileImageFile = File(xFile.path);
        emit(EditProfileImagePicked(imagePath: xFile.path));
      }
    } catch (e) {
      emit(EditProfileFailure(message: e.toString()));
    }
  }

  /// Opens the gallery to let the user pick a new cover picture.
  Future<void> pickCoverImage() async {
    try {
      final xFile = await filePickerServices.pickImage();
      if (xFile != null) {
        _coverImageFile = File(xFile.path);
        emit(EditProfileCoverPicked(coverPath: xFile.path));
      }
    } catch (e) {
      emit(EditProfileFailure(message: e.toString()));
    }
  }

  Future<void> editProfile({
    required String? name,
    required String? title,
    required String? existingImageUrl,
    required String? existingCoverUrl,
  }) async {
    emit(EditProfileLoading());
    try {
      final user = await coreAuthServices.getCurrentUserData();
      if (user == null) {
        emit(EditProfileFailure(message: 'User not found'));
        return;
      }
      await profileServices.updateProfile(
        userId: user.id,
        name: name,
        title: title,
        imageUrl: existingImageUrl,
        coverUrl: existingCoverUrl,
        profileImageFile: _profileImageFile,
        coverImageFile: _coverImageFile,
      );
      emit(EditProfileSuccess());
    } catch (e) {
      emit(EditProfileFailure(message: e.toString()));
    }
  }
}
