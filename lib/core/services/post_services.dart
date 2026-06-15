import 'dart:io';

import 'package:social_media_app/core/app_constants.dart';
import 'package:social_media_app/core/services/supabase_database_services.dart';
import 'package:social_media_app/core/theme/app_tables_names.dart';
import 'package:social_media_app/core/models/comment_model.dart';
import 'package:social_media_app/core/models/comment_request_body.dart';
import 'package:social_media_app/core/models/comment_model.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostServices {
  final supabaseServices = SupabaseDatabaseServices.instance;
  final supabaseStorageClient = Supabase.instance.client.storage;
  Future<PostModel> fetchPostById(String postId) async {
    try {
      return await supabaseServices.fetchRow(
        table: AppTablesNames.posts,
        id: postId,
        builder: (data, id) {
          return PostModel.fromMap(data);
        },
        primaryKey: 'id',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PostModel>> fetchSavedPosts(List<String> postIds) async {
    try {
      if (postIds.isEmpty) return [];
      return await supabaseServices.fetchRows(
        table: AppTablesNames.posts,
        builder: (data, id) {
          return PostModel.fromMap(data);
        },
        primaryKey: 'id',
        filter: (query) => query.inFilter('id', postIds),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<PostModel> likePost(String postId, String userId) async {
    try {
      var post = await supabaseServices.fetchRow(
        table: AppTablesNames.posts,
        id: postId,
        builder: (data, id) {
          return PostModel.fromMap(data);
        },
        primaryKey: 'id',
      );
      if (post.likes != null && post.likes!.contains(userId)) {
        post.likes?.remove(userId);
        post = post.copyWith(isLiked: false);
      } else {
        post = post.copyWith(likes: post.likes ?? []);
        post.likes?.add(userId);
        post = post.copyWith(isLiked: true);
      }
      await supabaseServices.updateRow(
        table: AppTablesNames.posts,
        column: 'id',
        values: post.toMap(),
        value: postId,
      );
      return post;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addComment({
    required String authorId,
    required String text,
    required File? image,
    required String postId,
    String? parentId,
  }) async {
    try {
      String? imageUrl;
      if (image != null) {
        imageUrl = await supabaseStorageClient
            .from(AppTablesNames.comments)
            .upload(
              'private/${DateTime.now().toIso8601String()}',
              image,
              fileOptions: FileOptions(cacheControl: '3600', upsert: true),
            );
      }
      final comment = CommentRequestBody(
        authorId: authorId,
        text: text,
        postId: postId,
        image: imageUrl != null
            ? '${AppConstants.supabaseStorageUrl}/$imageUrl'
            : null,
        parentId: parentId,
      );
      await supabaseServices.insertRow(
        table: AppTablesNames.comments,
        values: comment.toMap(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<CommentModel> likeComment(String commentId, String userId) async {
    try {
      var comment = await supabaseServices.fetchRow(
        table: AppTablesNames.comments,
        id: commentId,
        builder: (data, id) {
          return CommentModel.fromMap(data);
        },
        primaryKey: 'id',
      );
      if (comment.likes != null && comment.likes!.contains(userId)) {
        comment.likes?.remove(userId);
        comment = comment.copyWith(isLiked: false);
      } else {
        comment = comment.copyWith(likes: comment.likes ?? []);
        comment.likes?.add(userId);
        comment = comment.copyWith(isLiked: true);
      }
      await supabaseServices.updateRow(
        table: AppTablesNames.comments,
        column: 'id',
        values: comment.toMap(),
        value: commentId,
      );
      return comment;
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

  Future<void> deletePost(String postId) async {
    try {
      await supabaseServices.deleteRow(
        table: AppTablesNames.posts,
        column: 'id',
        value: postId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editPost(String postId, String text) async {
    try {
      await supabaseServices.updateRow(
        table: AppTablesNames.posts,
        column: 'id',
        value: postId,
        values: {'text': text},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PostModel>> fetchReels({int limit = 10, int offset = 0}) async {
    try {
      return await supabaseServices.fetchRows(
        table: AppTablesNames.posts,
        builder: (data, id) {
          return PostModel.fromMap(data);
        },
        primaryKey: 'id',
        filter: (query) => query.not('video', 'is', null).eq('is_private', false),
        orderBy: 'created_at',
        ascending: false,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      rethrow;
    }
  }
}

