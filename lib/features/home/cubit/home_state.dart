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