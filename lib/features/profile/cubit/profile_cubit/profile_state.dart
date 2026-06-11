part of 'profile_cubit.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileRefreshing extends ProfileState {}

final class ProfileSuccess extends ProfileState {
  final UserData user;
  ProfileSuccess(this.user);
}

final class ProfileFailure extends ProfileState {
  final String message;
  ProfileFailure(this.message);
}

final class ProfilePostsLoading extends ProfileState {}

final class ProfilePostsSuccess extends ProfileState {
  final List<PostModel> posts;
  ProfilePostsSuccess(this.posts);
}

final class ProfilePostsFailure extends ProfileState {
  final String message;
  ProfilePostsFailure(this.message);
}
