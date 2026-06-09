part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class StoryLoading extends HomeState {}

final class StoryLoaded extends HomeState {
  final List<StoryModel> stories;

  StoryLoaded({required this.stories});
}

final class StoryError extends HomeState {
  final String error;

  StoryError({required this.error});
}

final class PostLoading extends HomeState {}

final class PostLoaded extends HomeState {
  final List<PostModel> posts;

  PostLoaded({required this.posts});
}

final class PostError extends HomeState {
  final String error;

  PostError({required this.error});
}

final class PostCreating extends HomeState {}

final class PostCreated extends HomeState {}

final class PostCreateError extends HomeState {
  final String error;

  PostCreateError({required this.error});
}

final class PostCreateInitialLoading extends HomeState {}

final class PostCreateInitialData extends HomeState {
  final UserData user;

  PostCreateInitialData({required this.user});
}

final class FileUploading extends HomeState {}

final class FileUploaded extends HomeState {
  final File file;

  FileUploaded({required this.file});
}

final class FileUploadError extends HomeState {
  final String error;

  FileUploadError({required this.error});
}

final class PickingImage extends HomeState {}

final class ImagePicked extends HomeState {
  final File image;

  ImagePicked({required this.image});
}

final class PickingImageError extends HomeState {
  final String error;

  PickingImageError({required this.error});
}

final class PickingVideo extends HomeState {}

final class VideoPicked extends HomeState {
  final File video;

  VideoPicked({required this.video});
}

final class PickingVideoError extends HomeState {
  final String error;

  PickingVideoError({required this.error});
}

final class ImageCleared extends HomeState {}
final class VideoCleared extends HomeState {}
final class FileCleared extends HomeState {}

