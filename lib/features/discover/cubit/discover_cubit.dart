import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/features/discover/views/services/discover_services.dart';
import 'package:social_media_app/features/profile/services/profile_services.dart';

part 'discover_state.dart';

class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit() : super(DiscoverInitial());

  final discoverServices = DiscoverServices();

  Future<void> fetchAllUsers() async {
    try {
      emit(DiscoverLoading());
      final users = await discoverServices.fetchAllUsers();
      emit(DiscoverSuccess(users: users));
    } catch (e) {
      emit(DiscoverFailure(errorMessage: e.toString()));
    }
  }

  Future<void> toggleFollowUser(String targetUserId) async {
    final currentState = state;
    if (currentState is DiscoverSuccess) {
      try {
        final currentUserId = discoverServices.supabase.auth.currentUser?.id;
        if (currentUserId == null) return;

        // Optimistically update the list of users in the state
        final updatedUsers = currentState.users.map((user) {
          if (user.id == targetUserId) {
            final List<String> followers = List<String>.from(user.followers ?? []);
            if (followers.contains(currentUserId)) {
              followers.remove(currentUserId);
            } else {
              followers.add(currentUserId);
            }
            return user.copyWith(
              followers: followers,
              followersCount: followers.length,
            );
          }
          return user;
        }).toList();

        emit(DiscoverSuccess(users: updatedUsers));

        // Call background service to update DB
        await ProfileServices().toggleFollowUser(
          currentUserId: currentUserId,
          targetUserId: targetUserId,
        );
      } catch (e) {
        // Fallback: fetch original data on error to keep UI in sync
        await fetchAllUsers();
      }
    }
  }
}

