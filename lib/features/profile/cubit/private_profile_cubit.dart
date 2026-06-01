import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/features/profile/services/private_profile_services.dart';

part 'private_profile_state.dart';

class PrivateProfileCubit extends Cubit<PrivateProfileState> {
  PrivateProfileCubit() : super(ProfileInitial());
  final coreAuthServices = CoreAuthServices();
  final privateProfileServices = PrivateProfileServices();
  Future<void> fetchUserProfile() async {
    emit(ProfileLoading());
    try {
      final user = await coreAuthServices.getCurrentUserData();
      if (user == null) {
        emit(ProfileFailure("User not found"));
        return;
      }
      emit(ProfileSuccess(user));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }
}
