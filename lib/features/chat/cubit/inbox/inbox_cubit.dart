import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/models/chat_model.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/features/chat/services/chat_services.dart';
import 'package:social_media_app/core/theme/app_tables_names.dart';
import 'inbox_state.dart';
import 'package:social_media_app/core/di/service_locator.dart';

class InboxCubit extends Cubit<InboxState> {
  InboxCubit() : super(InboxInitial());

  StreamSubscription? _inboxSubscription;
  final ChatServices _chatServices = sl<ChatServices>();
  final CoreAuthServices _coreAuthServices = sl<CoreAuthServices>();
  final Map<String, UserData> _profileCache = {};

  void listenToInbox() async {
    emit(InboxLoading());
    try {
      final currentUser = await _coreAuthServices.getCurrentUserData();
      if (currentUser == null) {
        emit(InboxFailure("User not authenticated"));
        return;
      }
      final currentUserId = currentUser.id;

      _inboxSubscription?.cancel();
      _inboxSubscription = _chatServices.subscribeToInbox().listen((rawChats) async {
        try {
          // Find which other user profiles are missing from cache
          final missingIds = <String>[];
          for (var chat in rawChats) {
            final otherId = chat.participantOne == currentUserId ? chat.participantTwo : chat.participantOne;
            if (!_profileCache.containsKey(otherId)) {
              missingIds.add(otherId);
            }
          }

          // Fetch missing profiles in batch
          if (missingIds.isNotEmpty) {
            final fetchedProfiles = await _chatServices.dbServices.fetchRows<UserData>(
              table: AppTablesNames.users,
              primaryKey: 'id',
              builder: (data, id) => UserData.fromMap(data),
              filter: (query) => query.inFilter('id', missingIds),
            );
            for (var profile in fetchedProfiles) {
              _profileCache[profile.id] = profile;
            }
          }

          // Fetch unread messages count for each chat room
          final unreadResponse = await _chatServices.supabase
              .from(AppTablesNames.messages)
              .select('chat_id')
              .eq('recipient_id', currentUserId)
              .eq('is_read', false);
          
          final Map<String, int> unreadCounts = {};
          for (var item in unreadResponse as List) {
            final chatId = item['chat_id'] as String;
            unreadCounts[chatId] = (unreadCounts[chatId] ?? 0) + 1;
          }

          // Build populated chats
          final List<ChatModel> fullChats = [];
          for (var chat in rawChats) {
            final otherId = chat.participantOne == currentUserId ? chat.participantTwo : chat.participantOne;
            // Only keep chats where other user profile exists or is fetched
            if (_profileCache.containsKey(otherId)) {
              fullChats.add(chat.copyWith(otherUser: _profileCache[otherId]));
            } else {
              // If the profile is still not found, we can fetch it individually as fallback
              try {
                final user = await _coreAuthServices.getUserData(otherId);
                if (user != null) {
                  _profileCache[otherId] = user;
                  fullChats.add(chat.copyWith(otherUser: user));
                }
              } catch (_) {}
            }
          }

          // Sort by last message time or update time descending
          fullChats.sort((a, b) {
            final timeA = a.lastMessageTime ?? a.updatedAt;
            final timeB = b.lastMessageTime ?? b.updatedAt;
            return timeB.compareTo(timeA);
          });

          emit(InboxSuccess(
            chats: fullChats,
            unreadCounts: unreadCounts,
            currentUserId: currentUserId,
          ));
        } catch (e) {
          emit(InboxFailure(e.toString()));
        }
      });
    } catch (e) {
      emit(InboxFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _inboxSubscription?.cancel();
    return super.close();
  }
}
