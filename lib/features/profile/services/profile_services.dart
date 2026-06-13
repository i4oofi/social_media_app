import 'dart:io';

import 'package:social_media_app/core/models/comment_model.dart';
import 'package:social_media_app/core/services/supabase_database_services.dart';
import 'package:social_media_app/core/theme/app_tables_names.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:social_media_app/core/models/notification_model.dart';
import 'package:social_media_app/core/services/notification_services.dart';

class ProfileServices {
  final supabaseServices = SupabaseDatabaseServices.instance;
  final supabaseStorageClient = Supabase.instance.client.storage;

  Future<List<PostModel>> fetchUserPosts(String userId, {int limit = 10, int offset = 0}) async {
    try {
      return await supabaseServices.fetchRows(
        table: AppTablesNames.posts,
        builder: (data, id) {
          return PostModel.fromMap(data);
        },
        primaryKey: 'id',
        orderBy: 'created_at',
        ascending: false,
        limit: limit,
        offset: offset,
        filter: (query) => query.eq('author_id', userId),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CommentModel>> fetchComments(String postId) async {
    try {
      return await supabaseServices.fetchRows(
        table: AppTablesNames.comments,
        builder: (data, id) {
          return CommentModel.fromMap(data);
        },
        primaryKey: 'id',
        filter: (query) => query.eq('post_id', postId),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Uploads an image file to Supabase Storage under [bucket] and returns the public URL.
  Future<String> _uploadImage({
    required File imageFile,
    required String bucket,
    required String userId,
    required String prefix,
  }) async {
    final path = '$userId/$prefix-${DateTime.now().millisecondsSinceEpoch}.jpg';
    await supabaseStorageClient
        .from(bucket)
        .upload(
          path,
          imageFile,
          fileOptions: FileOptions(cacheControl: '3600', upsert: true),
        );
    final publicUrl =
        supabaseStorageClient.from(bucket).getPublicUrl(path);
    return publicUrl;
  }

  Future<void> updateProfile({
    required String userId,
    required String? name,
    String? title,
    String? imageUrl,
    String? coverUrl,
    File? profileImageFile,
    File? coverImageFile,
  }) async {
    try {
      String? finalImageUrl = imageUrl;
      String? finalCoverUrl = coverUrl;

      if (profileImageFile != null) {
        finalImageUrl = await _uploadImage(
          imageFile: profileImageFile,
          bucket: 'avatars',
          userId: userId,
          prefix: 'profile',
        );
      }

      if (coverImageFile != null) {
        finalCoverUrl = await _uploadImage(
          imageFile: coverImageFile,
          bucket: 'covers',
          userId: userId,
          prefix: 'cover',
        );
      }

      final data = <String, dynamic>{
        'name': name,
        'title': title,
        'image_url': finalImageUrl,
        'cover_url': finalCoverUrl,
      };

      await supabaseServices.updateRow(
        table: AppTablesNames.users,
        values: data,
        column: 'id',
        value: userId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleFollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      // 1. Update target user's followers list
      final targetUser = await supabaseServices.fetchRow(
        table: AppTablesNames.users,
        primaryKey: 'id',
        id: targetUserId,
        builder: (data, id) => UserData.fromMap(data),
      );
      final List<String> followers = List<String>.from(
        targetUser.followers ?? [],
      );
      bool isNowFollowing = false;
      if (followers.contains(currentUserId)) {
        followers.remove(currentUserId);
      } else {
        followers.add(currentUserId);
        isNowFollowing = true;
      }
      await supabaseServices.updateRow(
        table: AppTablesNames.users,
        values: {
          'followers': followers,
          'followers_count': followers.length,
        },
        column: 'id',
        value: targetUserId,
      );

      // 2. Update current user's following list
      final currentUser = await supabaseServices.fetchRow(
        table: AppTablesNames.users,
        primaryKey: 'id',
        id: currentUserId,
        builder: (data, id) => UserData.fromMap(data),
      );
      final List<String> following = List<String>.from(
        currentUser.following ?? [],
      );
      if (following.contains(targetUserId)) {
        following.remove(targetUserId);
      } else {
        following.add(targetUserId);
      }
      await supabaseServices.updateRow(
        table: AppTablesNames.users,
        values: {
          'following': following,
          'following_count': following.length,
        },
        column: 'id',
        value: currentUserId,
      );

      if (isNowFollowing) {
        final notification = NotificationModel(
          id: '',
          createdAt: '',
          receiverId: targetUserId,
          senderId: currentUserId,
          type: 'follow',
          isRead: false,
        );
        await NotificationServices().createNotification(notification);
      }
    } catch (e) {
      rethrow;
    }
  }
}
