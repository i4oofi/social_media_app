import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/core/services/file_picker_services.dart';
import 'package:social_media_app/core/services/home_services.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/features/home/models/comment_model.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/features/home/models/post_request_body.dart';
import 'package:social_media_app/features/home/models/story_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());
  final homeServices = HomeServices();
  final coreAuthServices = CoreAuthServices();
  final filePickerServices = FilePickerServices();
  File? currentImage;
  File? currentFile;
  Future<void> fetchStories() async {
    try {
      emit(StoryLoading());
      final rawStories = await homeServices.fetchStories();
      List<StoryModel> stories = [];
      for (var story in rawStories) {
        final userData = await coreAuthServices.getUserData(story.authorId);
        if (userData != null) {
          story = story.copyWith(authorName: userData.name);
        }
        stories.add(story);
      }

      emit(StoryLoaded(stories: stories));
    } catch (e) {
      emit(StoryError(error: e.toString()));
    }
  }

  Future<void> fetchPosts() async {
    try {
      emit(PostLoading());
      final rawPosts = await homeServices.fetchPosts();
      List<PostModel> posts = [];
      for (var post in rawPosts) {
        final userData = await coreAuthServices.getUserData(post.authorId);
        final comments = await homeServices.fetchComments(post.id);
        if (userData != null) {
          post = post.copyWith(
            authorName: userData.name,
            authorProfileImage: userData.imageUrl,
            isLiked: post.likes?.contains(userData.id) ?? false,
            commentCount: comments.length,
          );
        }
        posts.add(post);
      }

      emit(PostLoaded(posts: posts));
    } catch (e) {
      emit(PostError(error: e.toString()));
    }
  }

  Future<void> createPost({required String text}) async {
    try {
      final currentUser = await coreAuthServices.getCurrentUserData();
      if (currentUser != null) {
        emit(PostCreating());
        await homeServices.createPost(
          PostRequestBody(text: text, authorId: currentUser.id),
          currentImage,
          currentFile,
        );
        emit(PostCreated());
      }
    } catch (e) {
      emit(PostCreateError(error: e.toString()));
    }
  }

  Future<void> fetchInitialCreatePostData() async {
    try {
      emit(PostCreateInitialLoading());
      final user = await coreAuthServices.getCurrentUserData();
      if (user != null) {
        emit(PostCreateInitialData(user: user));
      }
    } catch (e) {
      emit(PostCreateError(error: e.toString()));
    }
  }

  Future<void> refresh() async {
    try {
      await fetchStories();
      await fetchPosts();
    } catch (e) {
      emit(StoryError(error: e.toString()));
      emit(PostError(error: e.toString()));
    }
  }

  Future<void> pickImage() async {
    emit(PickingImage());
    try {
      final image = await filePickerServices.pickImage();
      if (image != null) {
        currentImage = File(image.path);
        emit(ImagePicked(image: File(image.path)));
      }
    } catch (e) {
      emit(PickingImageError(error: e.toString()));
    }
  }

  Future<void> takeImage() async {
    emit(PickingImage());
    try {
      final image = await filePickerServices.takeImage();
      if (image != null) {
        currentImage = File(image.path);
        emit(ImagePicked(image: File(image.path)));
      }
    } catch (e) {
      emit(PickingImageError(error: e.toString()));
    }
  }

  Future<void> uploadFile() async {
    emit(FileUploading());
    try {
      final file = await filePickerServices.pickFile();
      if (file != null) {
        currentFile = File(file.path);
        emit(FileUploaded(file: File(file.path)));
      }
    } catch (e) {
      emit(FileUploadError(error: e.toString()));
    }
  }

  Future<void> likePost(String postId) async {
    try {
      final currentUser = await coreAuthServices.getCurrentUserData();
      if (currentUser != null) {
        emit(PostLiking(postId: postId));
        final updatedPost = await homeServices.likePost(postId, currentUser.id);
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
      final post = await homeServices.fetchPostById(postId);
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
        await homeServices.addComment(
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
      final rawComments = await homeServices.fetchComments(postId);
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
