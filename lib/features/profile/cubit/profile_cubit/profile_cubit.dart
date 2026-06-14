import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/features/profile/services/profile_services.dart';
import 'package:social_media_app/core/services/post_services.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());
  final coreAuthServices = CoreAuthServices();
  final profileServices = ProfileServices();
  final postServices = PostServices();

  Future<void> fetchUserProfile({String? userId, bool silent = false}) async {
    if (!silent) {
      emit(ProfileLoading());
    } else {
      emit(ProfileRefreshing());
    }
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

  int _postOffset = 0;
  final int _postLimit = 10;
  bool _hasReachedMax = false;
  List<PostModel> _userPosts = [];
  bool _isLoadingMore = false;

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
      
      _postOffset = 0;
      _hasReachedMax = false;
      _userPosts.clear();

      final rawUserPosts = await profileServices.fetchUserPosts(
        userModel.id,
        limit: _postLimit,
        offset: _postOffset,
      );
      
      if (rawUserPosts.length < _postLimit) {
        _hasReachedMax = true;
      }

      final List<PostModel> userPosts = [];
      for (var rawPost in rawUserPosts) {
        if (rawPost.isPrivate && currentAuthUser?.id != userModel.id) continue;
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
      
      _userPosts = userPosts;
      _postOffset += _postLimit;

      emit(ProfilePostsSuccess(List.from(_userPosts), hasReachedMax: _hasReachedMax));
    } catch (e) {
      emit(ProfilePostsFailure(e.toString()));
    }
  }

  Future<void> loadMoreUserPosts({String? userId}) async {
    if (_hasReachedMax || _isLoadingMore) return;

    try {
      _isLoadingMore = true;
      emit(ProfilePostsSuccess(List.from(_userPosts), hasReachedMax: _hasReachedMax, isLoadingMore: true));
      
      final currentAuthUser = await coreAuthServices.getCurrentUserData();
      final UserData? userModel;
      if (userId == null) {
        userModel = currentAuthUser;
      } else {
        userModel = await coreAuthServices.getUserData(userId);
      }
      
      if (userModel == null) {
        _isLoadingMore = false;
        emit(ProfilePostsSuccess(List.from(_userPosts), hasReachedMax: _hasReachedMax, isLoadingMore: false));
        return;
      }

      final rawUserPosts = await profileServices.fetchUserPosts(
        userModel.id,
        limit: _postLimit,
        offset: _postOffset,
      );
      
      if (rawUserPosts.isEmpty) {
        _hasReachedMax = true;
        _isLoadingMore = false;
        emit(ProfilePostsSuccess(List.from(_userPosts), hasReachedMax: _hasReachedMax, isLoadingMore: false));
        return;
      }
      
      if (rawUserPosts.length < _postLimit) {
        _hasReachedMax = true;
      }

      final List<PostModel> newPosts = [];
      for (var rawPost in rawUserPosts) {
        if (rawPost.isPrivate && currentAuthUser?.id != userModel.id) continue;
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
        newPosts.add(rawPost);
      }
      
      _userPosts.addAll(newPosts);
      _postOffset += _postLimit;

      _isLoadingMore = false;
      emit(ProfilePostsSuccess(List.from(_userPosts), hasReachedMax: _hasReachedMax, isLoadingMore: false));
    } catch (e) {
      // Don't emit failure state to avoid destroying current loaded posts
      _isLoadingMore = false;
      emit(ProfilePostsSuccess(List.from(_userPosts), hasReachedMax: _hasReachedMax, isLoadingMore: false));
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

      // Optimistic update for smooth UI
      if (state is ProfileSuccess) {
        final currentUserData = (state as ProfileSuccess).user;
        final currentFollowers = List<String>.from(currentUserData.followers ?? []);
        
        if (currentFollowers.contains(currentAuthUser.id)) {
          currentFollowers.remove(currentAuthUser.id);
        } else {
          currentFollowers.add(currentAuthUser.id);
        }
        
        final updatedUser = currentUserData.copyWith(
          followers: currentFollowers,
          followersCount: currentFollowers.length,
        );
        emit(ProfileSuccess(updatedUser));
      }

      await profileServices.toggleFollowUser(
        currentUserId: currentAuthUser.id,
        targetUserId: targetUserId,
      );
      // Fetch silently to ensure consistency without full screen shimmer
      await fetchUserProfile(userId: targetUserId, silent: true);
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> deletePost(String postId, {String? userId}) async {
    try {
      emit(ProfilePostsLoading());
      await postServices.deletePost(postId);
      await fetchUserPosts(userId: userId);
    } catch (e) {
      emit(ProfilePostsFailure(e.toString()));
    }
  }

  Future<void> editPost(String postId, String text, {String? userId}) async {
    try {
      emit(ProfilePostsLoading());
      await postServices.editPost(postId, text);
      await fetchUserPosts(userId: userId);
    } catch (e) {
      emit(ProfilePostsFailure(e.toString()));
    }
  }
}
