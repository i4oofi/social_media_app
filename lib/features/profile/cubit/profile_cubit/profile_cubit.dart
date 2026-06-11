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
  Future<void> fetchUserProfile({String? userId, bool silent = false}) async {
    if (!silent) emit(ProfileLoading());
    else emit(ProfileRefreshing());
    try {
      final UserData? userModel;
      if (userId == null) {
        userModel = await coreAuthServices.getCurrentUserData();
      } else {
        userModel = await coreAuthServices.getUserData(userId);
      }
      if (userModel == null) {
        emit(ProfileFailure("User not found"));
        return;
      }
      final userPosts = await profileServices.fetchUserPosts(userModel.id);
      final user = userModel.copyWith(postsCount: userPosts.length);
      emit(ProfileSuccess(user));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> fetchUserPosts({String? userId, bool silent = false}) async {
    if (!silent) emit(ProfilePostsLoading());
    try {
      final currentAuthUser = await coreAuthServices.getCurrentUserData();
      final UserData? userModel;
      if (userId == null) {
        userModel = currentAuthUser;
      } else {
        userModel = await coreAuthServices.getUserData(userId);
      }
      if (userModel == null) {
        emit(ProfilePostsFailure("User not found"));
        return;
      }
      final rawUserPosts = await profileServices.fetchUserPosts(userModel.id);
      final List<PostModel> userPosts = [];
      for (var rawPost in rawUserPosts) {
        final postAuthor = await coreAuthServices.getUserData(rawPost.authorId);
        final comments = await profileServices.fetchComments(rawPost.id);
        rawPost = rawPost.copyWith(commentCount: comments.length);
        if (postAuthor != null) {
          rawPost = rawPost.copyWith(
            authorName: postAuthor.name,
            authorProfileImage: postAuthor.imageUrl,
            isLiked: currentAuthUser != null ? rawPost.likes?.contains(currentAuthUser.id) : false,
          );
        }
        userPosts.add(rawPost);
      }
      emit(ProfilePostsSuccess(userPosts));
    } catch (e) {
      emit(ProfilePostsFailure(e.toString()));
    }
  }

  /// Silent pull-to-refresh: does NOT show the full-page shimmer.
  Future<void> refreshProfile({String? userId}) async {
    await fetchUserProfile(userId: userId, silent: true);
    await fetchUserPosts(userId: userId, silent: true);
  }

  Future<void> toggleFollowUser(String targetUserId) async {
    try {
      final currentAuthUser = await coreAuthServices.getCurrentUserData();
      if (currentAuthUser == null) return;
      await profileServices.toggleFollowUser(
        currentUserId: currentAuthUser.id,
        targetUserId: targetUserId,
      );
      await fetchUserProfile(userId: targetUserId);
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }
}
