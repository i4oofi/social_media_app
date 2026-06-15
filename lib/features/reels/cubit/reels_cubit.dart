import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/services/post_services.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/features/profile/services/profile_services.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'reels_state.dart';

class ReelsCubit extends Cubit<ReelsState> {
  final PostServices _postServices;
  final CoreAuthServices _coreAuthServices = CoreAuthServices();
  final ProfileServices _profileServices = ProfileServices();

  ReelsCubit(this._postServices) : super(ReelsInitial());

  Future<void> fetchReels({bool refresh = false}) async {
    try {
      if (state is ReelsLoading) return;
      
      int offset = 0;
      List<PostModel> currentReels = [];
      
      if (refresh) {
        emit(ReelsLoading());
      } else if (state is ReelsLoaded) {
        final currentState = state as ReelsLoaded;
        if (currentState.hasReachedMax) return;
        currentReels = currentState.reels;
        offset = currentReels.length;
      } else {
        emit(ReelsLoading());
      }

      final rawReels = await _postServices.fetchReels(offset: offset, limit: 10);
      final currentUser = await _coreAuthServices.getCurrentUserData();
      
      List<PostModel> newReels = [];
      for (var reel in rawReels) {
        final userData = await _coreAuthServices.getUserData(reel.authorId);
        final comments = await _postServices.fetchComments(reel.id);
        if (userData != null) {
          reel = reel.copyWith(
            authorName: userData.name,
            authorProfileImage: userData.imageUrl,
            isLiked: currentUser != null ? reel.likes?.contains(currentUser.id) ?? false : false,
            commentCount: comments.length,
            isFollowingAuthor: currentUser != null ? userData.followers?.contains(currentUser.id) ?? false : false,
          );
        }
        newReels.add(reel);
      }
      
      emit(ReelsLoaded(
        reels: currentReels + newReels,
        hasReachedMax: rawReels.length < 10,
      ));
    } catch (e) {
      emit(ReelsError(e.toString()));
    }
  }

  Future<void> toggleFollow(String authorId) async {
    try {
      final currentUser = await _coreAuthServices.getCurrentUserData();
      if (currentUser == null) return;
      
      if (state is ReelsLoaded) {
        final currentState = state as ReelsLoaded;
        final updatedReels = currentState.reels.map((reel) {
          if (reel.authorId == authorId) {
            final isFollowing = reel.isFollowingAuthor ?? false;
            return reel.copyWith(isFollowingAuthor: !isFollowing);
          }
          return reel;
        }).toList();
        
        emit(ReelsLoaded(reels: updatedReels, hasReachedMax: currentState.hasReachedMax));
      }

      await _profileServices.toggleFollowUser(
        currentUserId: currentUser.id,
        targetUserId: authorId,
      );
    } catch (e) {
      // Revert logic could be implemented here on error
    }
  }

  Future<void> toggleLike(String postId) async {
    try {
      final currentUser = await _coreAuthServices.getCurrentUserData();
      if (currentUser == null) return;
      
      if (state is ReelsLoaded) {
        final currentState = state as ReelsLoaded;
        final updatedReels = currentState.reels.map((reel) {
          if (reel.id == postId) {
            final isLiked = reel.isLiked;
            final likes = List<String>.from(reel.likes ?? []);
            if (isLiked) {
              likes.remove(currentUser.id);
            } else {
              likes.add(currentUser.id);
            }
            return reel.copyWith(isLiked: !isLiked, likes: likes);
          }
          return reel;
        }).toList();
        
        emit(ReelsLoaded(reels: updatedReels, hasReachedMax: currentState.hasReachedMax));
      }

      await _postServices.likePost(postId, currentUser.id);
    } catch (e) {
      // Revert logic could be implemented here on error
    }
  }
}
