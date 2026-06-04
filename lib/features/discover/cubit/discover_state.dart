part of 'discover_cubit.dart';

@immutable
sealed class DiscoverState {}

final class DiscoverInitial extends DiscoverState {}

final class DiscoverLoading extends DiscoverState {}

final class DiscoverSuccess extends DiscoverState {
  final List<UserData> users;
  DiscoverSuccess({required this.users});
}

final class DiscoverFailure extends DiscoverState {
  final String errorMessage;
  DiscoverFailure({required this.errorMessage});
}
