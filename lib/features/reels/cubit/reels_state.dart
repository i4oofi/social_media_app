import 'package:social_media_app/features/home/models/post_model.dart';

abstract class ReelsState {}

class ReelsInitial extends ReelsState {}

class ReelsLoading extends ReelsState {}

class ReelsLoaded extends ReelsState {
  final List<PostModel> reels;
  final bool hasReachedMax;

  ReelsLoaded({required this.reels, this.hasReachedMax = false});
}

class ReelsError extends ReelsState {
  final String message;

  ReelsError(this.message);
}
