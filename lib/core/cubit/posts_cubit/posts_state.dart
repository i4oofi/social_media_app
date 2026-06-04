part of 'posts_cubit.dart';

@immutable
sealed class PostsState {}

final class PostsInitial extends PostsState {}
final class PostLiking extends PostsState {
  final String postId;
  PostLiking({required this.postId});
}

final class PostLiked extends PostsState {
  final String postId;
  final int likesCount;
  final bool isLiked;
  PostLiked({required this.postId, this.likesCount = 0, required this.isLiked});
}

final class PostLikeError extends PostsState {
  final String error;
  final String postId;

  PostLikeError({required this.error, required this.postId});
}
final class FetchingLikersDetails extends PostsState {}

final class LikersDetailsFetched extends PostsState {
  final List<UserData> likersDetails;

  LikersDetailsFetched({required this.likersDetails});
}

final class FetchingLikersDetailsError extends PostsState {
  final String error;

  FetchingLikersDetailsError({required this.error});
}

final class CommentAdding extends PostsState{}

final class CommentAdded extends PostsState{}

final class CommentAddingError extends PostsState{
  final String error;
  CommentAddingError({required this.error});
}

final class CommentsFetching extends PostsState{}

final class CommentsFetched extends PostsState{
  final List<CommentModel> comments;
  CommentsFetched({required this.comments});
}

final class CommentsError extends PostsState{
  final String error;
  CommentsError({required this.error});
}