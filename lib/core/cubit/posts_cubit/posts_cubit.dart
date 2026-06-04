import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/core/services/file_picker_services.dart';
import 'package:social_media_app/core/services/post_services.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/core/models/comment_model.dart';

part 'posts_state.dart';

class PostsCubit extends Cubit<PostsState> {
  PostsCubit() : super(PostsInitial());

  final postServices = PostServices();
  final coreAuthServices = CoreAuthServices();
  final filePickerServices = FilePickerServices();
  File? currentImage;
  File? currentFile;

    Future<void> likePost(String postId) async {
    try {
      final currentUser = await coreAuthServices.getCurrentUserData();
      if (currentUser != null) {
        emit(PostLiking(postId: postId));
        final updatedPost = await postServices.likePost(postId, currentUser.id);
        emit(
          PostLiked(
            postId: postId,
            likesCount: updatedPost.likes?.length ?? 0,
            isLiked: updatedPost.likes!.contains(currentUser.id),
          ),
        );
      }
    } catch (e) {
      emit(PostLikeError(error: e.toString(), postId: postId));
    }
  }

  Future<void> fetchPostLikesDetails(String postId) async {
    try {
      emit(FetchingLikersDetails());
      final post = await postServices.fetchPostById(postId);
      List<UserData> likersDetails = [];
      for (var likerId in post.likes!) {
        final userData = await coreAuthServices.getUserData(likerId);
        if (userData != null) {
          likersDetails.add(userData);
        }
      }
      emit(LikersDetailsFetched(likersDetails: likersDetails));
    } catch (e) {
      emit(FetchingLikersDetailsError(error: e.toString()));
    }
  }

  Future<void> addComment(String postId, String text) async {
    try {
      final currentUser = await coreAuthServices.getCurrentUserData();
      if (currentUser != null) {
        emit(CommentAdding());
        await postServices.addComment(
          postId: postId,
          text: text,
          authorId: currentUser.id,
          image: currentImage,
        );
        emit(CommentAdded());
      }
    } catch (e) {
      emit(CommentAddingError(error: e.toString()));
    }
  }

  Future<void> fetchComments(String postId) async {
    try {
      emit(CommentsFetching());
      final rawComments = await postServices.fetchComments(postId);
      List<CommentModel> comments = [];
      for (var comment in rawComments) {
        final userData = await coreAuthServices.getUserData(comment.authorId);
        if (userData != null) {
          comment = comment.copyWith(
            authorName: userData.name,
            authorImage: userData.imageUrl,
          );
        }
        comments.add(comment);
      }
      emit(CommentsFetched(comments: comments));
    } catch (e) {
      emit(CommentsError(error: e.toString()));
    }
  }
}
