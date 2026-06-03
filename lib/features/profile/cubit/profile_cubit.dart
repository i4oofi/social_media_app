import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/features/profile/services/profile_services.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());
  final coreAuthServices = CoreAuthServices();
  final profileServices = ProfileServices();
  Future<void> fetchUserProfile() async {
    emit(ProfileLoading());
    try {
      final userModel = await coreAuthServices.getCurrentUserData();
      if (userModel == null) {
        emit(ProfileFailure("User not found"));
        return;
      }
      final userPosts = await profileServices.fetchUserPosts(userModel.id);
      var user = userModel.copyWith(postsCount: userPosts.length);
      user = user.copyWith(postsCount: userPosts.length);
      emit(ProfileSuccess(user));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> fetchUserPosts() async {
    emit(ProfilePostsLoading());
    try {
      final userModel = await coreAuthServices.getCurrentUserData();
      if (userModel == null) {
        emit(ProfilePostsFailure("User not found"));
        return;
      }
      final userPosts = await profileServices.fetchUserPosts(userModel.id);
      emit(ProfilePostsSuccess(userPosts));
    } catch (e) {
      emit(ProfilePostsFailure(e.toString()));
    }
  }
}
