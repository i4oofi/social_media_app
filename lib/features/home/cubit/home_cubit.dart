import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/core/services/file_picker_services.dart';
import 'package:social_media_app/core/services/post_services.dart';
import 'package:social_media_app/features/home/services/home_services.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/features/home/models/post_request_body.dart';
import 'package:social_media_app/features/home/models/story_model.dart';
import 'package:social_media_app/core/di/service_locator.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());
  final homeServices = sl<HomeServices>();
  final coreAuthServices = sl<CoreAuthServices>();
  final filePickerServices = sl<FilePickerServices>();
  final postServices = sl<PostServices>();
  File? currentImage;
  File? currentFile;
  File? currentVideo;
  bool isPostPrivate = false;

  void togglePostPrivacy() {
    isPostPrivate = !isPostPrivate;
    emit(PostPrivacyToggled(isPrivate: isPostPrivate));
  }
  Future<void> fetchStories() async {
    try {
      emit(StoryLoading());
      final currentUser = await coreAuthServices.getCurrentUserData();
      final currentUserId = currentUser?.id;
      final rawStories = await homeServices.fetchStories();
      List<StoryModel> stories = [];
      for (var story in rawStories) {
        final userData = await coreAuthServices.getUserData(story.authorId);
        if (userData != null) {
          story = story.copyWith(
            authorName: userData.name,
            authorProfileImage: userData.imageUrl,
          );
          final isOwnStory = story.authorId == currentUserId;
          final isFollower = userData.followers?.contains(currentUserId ?? '') ?? false;
          if (!story.isPrivate || isOwnStory || isFollower) {
            stories.add(story);
          }
        } else {
          if (!story.isPrivate) {
            stories.add(story);
          }
        }
      }

      emit(StoryLoaded(stories: stories));
    } catch (e) {
      emit(StoryError(error: e.toString()));
    }
  }

  int _postOffset = 0;
  final int _postLimit = 10;
  bool _hasReachedMax = false;
  List<PostModel> _allPosts = [];
  bool _isLoadingMore = false;

  Future<void> fetchPosts() async {
    try {
      emit(PostLoading());
      _postOffset = 0;
      _hasReachedMax = false;
      _allPosts.clear();
      
      final rawPosts = await homeServices.fetchPosts(
        limit: _postLimit,
        offset: _postOffset,
      );
      
      if (rawPosts.length < _postLimit) {
        _hasReachedMax = true;
      }

      final currentUser = await coreAuthServices.getCurrentUserData();

      List<PostModel> posts = [];
      for (var post in rawPosts) {
        if (post.isPrivate) continue;
        final userData = await coreAuthServices.getUserData(post.authorId);
        final comments = await postServices.fetchComments(post.id);
        if (userData != null) {
          post = post.copyWith(
            authorName: userData.name,
            authorProfileImage: userData.imageUrl,
            isLiked: currentUser != null ? post.likes?.contains(currentUser.id) ?? false : false,
            commentCount: comments.length,
          );
        }
        posts.add(post);
      }
      
      _allPosts = posts;
      _postOffset += _postLimit;

      emit(PostLoaded(posts: List.from(_allPosts), hasReachedMax: _hasReachedMax));
    } catch (e) {
      emit(PostError(error: e.toString()));
    }
  }

  Future<void> loadMorePosts() async {
    if (_hasReachedMax || _isLoadingMore) return;
    
    try {
      _isLoadingMore = true;
      emit(PostLoaded(posts: List.from(_allPosts), hasReachedMax: _hasReachedMax, isLoadingMore: true));

      final rawPosts = await homeServices.fetchPosts(
        limit: _postLimit,
        offset: _postOffset,
      );
      
      if (rawPosts.isEmpty) {
        _hasReachedMax = true;
        _isLoadingMore = false;
        emit(PostLoaded(posts: List.from(_allPosts), hasReachedMax: _hasReachedMax, isLoadingMore: false));
        return;
      }
      
      if (rawPosts.length < _postLimit) {
        _hasReachedMax = true;
      }

      final currentUser = await coreAuthServices.getCurrentUserData();

      List<PostModel> newPosts = [];
      for (var post in rawPosts) {
        if (post.isPrivate) continue;
        final userData = await coreAuthServices.getUserData(post.authorId);
        final comments = await postServices.fetchComments(post.id);
        if (userData != null) {
          post = post.copyWith(
            authorName: userData.name,
            authorProfileImage: userData.imageUrl,
            isLiked: currentUser != null ? post.likes?.contains(currentUser.id) ?? false : false,
            commentCount: comments.length,
          );
        }
        newPosts.add(post);
      }

      _allPosts.addAll(newPosts);
      _postOffset += _postLimit;

      _isLoadingMore = false;
      emit(PostLoaded(posts: List.from(_allPosts), hasReachedMax: _hasReachedMax, isLoadingMore: false));
    } catch (e) {
      // Don't emit PostError as it might disrupt the currently loaded posts.
      // Could potentially emit a specific pagination error state or just log.
      _isLoadingMore = false;
      emit(PostLoaded(posts: List.from(_allPosts), hasReachedMax: _hasReachedMax, isLoadingMore: false));
    }
  }

  Future<void> createPost({required String text}) async {
    try {
      final currentUser = await coreAuthServices.getCurrentUserData();
      if (currentUser != null) {
        emit(PostCreating());
        await homeServices.createPost(
          PostRequestBody(text: text, authorId: currentUser.id, isPrivate: isPostPrivate),
          currentImage,
          currentVideo,
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
        currentVideo = null;
        currentFile = null;
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
        currentVideo = null;
        currentFile = null;
        emit(ImagePicked(image: File(image.path)));
      }
    } catch (e) {
      emit(PickingImageError(error: e.toString()));
    }
  }

  Future<void> pickVideo() async {
    emit(PickingVideo());
    try {
      final video = await filePickerServices.pickVideo();
      if (video != null) {
        final file = File(video.path);
        final sizeInBytes = await file.length();
        final sizeInMb = sizeInBytes / (1024 * 1024);
        if (sizeInMb > 5) {
          emit(PickingVideoError(error: 'Video size exceeds 5MB limit. Please pick a smaller video.'));
          return;
        }
        currentVideo = file;
        currentImage = null;
        currentFile = null;
        emit(VideoPicked(video: file));
      }
    } catch (e) {
      emit(PickingVideoError(error: e.toString()));
    }
  }

  Future<void> takeVideo() async {
    emit(PickingVideo());
    try {
      final video = await filePickerServices.takeVideo();
      if (video != null) {
        final file = File(video.path);
        final sizeInBytes = await file.length();
        final sizeInMb = sizeInBytes / (1024 * 1024);
        if (sizeInMb > 5) {
          emit(PickingVideoError(error: 'Video size exceeds 5MB limit. Please record a shorter video.'));
          return;
        }
        currentVideo = file;
        currentImage = null;
        currentFile = null;
        emit(VideoPicked(video: file));
      }
    } catch (e) {
      emit(PickingVideoError(error: e.toString()));
    }
  }

  void clearImage() {
    currentImage = null;
    emit(ImageCleared());
  }

  void clearVideo() {
    currentVideo = null;
    emit(VideoCleared());
  }

  void clearFile() {
    currentFile = null;
    emit(FileCleared());
  }

  Future<void> uploadFile() async {
    emit(FileUploading());
    try {
      final file = await filePickerServices.pickFile();
      if (file != null) {
        currentFile = File(file.path);
        currentImage = null;
        currentVideo = null;
        emit(FileUploaded(file: File(file.path)));
      }
    } catch (e) {
      emit(FileUploadError(error: e.toString()));
    }
  }

  Future<void> shareStory() async {
    try {
      final image = await filePickerServices.pickImage();
      if (image == null) return;
      emit(StoryLoading());
      final currentUser = await coreAuthServices.getCurrentUserData();
      if (currentUser != null) {
        await homeServices.createStory(currentUser.id, File(image.path));
        await fetchStories();
      } else {
        emit(StoryError(error: "User not authenticated"));
      }
    } catch (e) {
      emit(StoryError(error: e.toString()));
    }
  }

  Future<void> uploadStory({required File image, required bool isPrivate}) async {
    try {
      emit(StoryLoading());
      final currentUser = await coreAuthServices.getCurrentUserData();
      if (currentUser != null) {
        await homeServices.createStory(currentUser.id, image, isPrivate: isPrivate);
        await fetchStories();
      } else {
        emit(StoryError(error: "User not authenticated"));
      }
    } catch (e) {
      emit(StoryError(error: e.toString()));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      emit(PostLoading());
      await postServices.deletePost(postId);
      await fetchPosts();
    } catch (e) {
      emit(PostError(error: e.toString()));
    }
  }

  Future<void> editPost(String postId, String text) async {
    try {
      emit(PostLoading());
      await postServices.editPost(postId, text);
      await fetchPosts();
    } catch (e) {
      emit(PostError(error: e.toString()));
    }
  }
}

