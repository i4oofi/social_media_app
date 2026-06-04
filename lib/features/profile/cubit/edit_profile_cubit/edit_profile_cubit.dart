import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/features/profile/services/profile_services.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit() : super(EditProfileInitial());
  final profileServices = ProfileServices();
  final coreAuthServices = CoreAuthServices();
  Future<void> editProfile(String? name , String? title , String? imageUrl) async {
    emit(EditProfileLoading());
    try {
      final user = await coreAuthServices.getCurrentUserData();
      if(user == null){
        emit(EditProfileFailure(message: 'User not found'));
        return;
      }
      await profileServices.updateProfile(
        userId: user.id,
        name: name,
        title: title,
        imageUrl: imageUrl,
      );
      emit(EditProfileSuccess());
    } catch (e) {
      emit(EditProfileFailure(message: e.toString()));
    }
  }
}
