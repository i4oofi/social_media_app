import 'dart:io';

import 'package:social_media_app/core/app_constants.dart';
import 'package:social_media_app/core/services/supabase_database_services.dart';
import 'package:social_media_app/core/theme/app_tables_names.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/core/shared/widgets/app_toast.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/features/home/models/post_request_body.dart';
import 'package:social_media_app/features/home/models/story_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeServices {
  final supabaseServices = SupabaseDatabaseServices.instance;
  final supabaseStorageClient = Supabase.instance.client.storage;

  Future<List<StoryModel>> fetchStories() async {
    try {
      return await supabaseServices.fetchRows(
        table: AppTablesNames.stories,
        builder: (data, id) {
          return StoryModel.fromMap(data);
        },
        primaryKey: 'id',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PostModel>> fetchPosts() async {
    try {
      return await supabaseServices.fetchRows(
        table: AppTablesNames.posts,
        builder: (data, id) {
          return PostModel.fromMap(data);
        },
        primaryKey: 'id',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createPost(PostRequestBody post, File? image, File? video, File? file) async {
    try {
      String? imageUrl;
      String? videoUrl;
      String? fileUrl;
      if (image != null) {
        final imageName = 'private/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
        imageUrl = await supabaseStorageClient
            .from(AppTablesNames.posts)
            .upload(
              imageName,
              image,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );
      }
      if (video != null) {
        final videoName = 'private/${DateTime.now().millisecondsSinceEpoch}_${video.path.split('/').last}';
        videoUrl = await supabaseStorageClient
            .from(AppTablesNames.posts)
            .upload(
              videoName,
              video,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );
      }
      if (file != null) {
        final fileName = 'private/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        fileUrl = await supabaseStorageClient
            .from(AppTablesNames.posts)
            .upload(
              fileName,
              file,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );
      }
      
      String? finalImageUrl = imageUrl != null ? '${AppConstants.supabaseStorageUrl}/$imageUrl' : null;
      String? finalVideoUrl = videoUrl != null ? '${AppConstants.supabaseStorageUrl}/$videoUrl' : null;
      String? finalFileUrl = fileUrl != null ? '${AppConstants.supabaseStorageUrl}/$fileUrl' : null;

      post = post.copyWith(
        imageUrl: finalImageUrl ?? post.imageUrl,
        video: finalVideoUrl ?? post.video,
        file: finalFileUrl ?? post.file,
      );

      await supabaseServices.insertRow(
        table: AppTablesNames.posts,
        values: post.toMap(),
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

  Future<void> createStory(String authorId, File image, {bool isPrivate = false}) async {
    try {
      final fileName = 'private/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = await supabaseStorageClient
          .from(AppTablesNames.posts)
          .upload(
            fileName,
            image,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );
      final imageUrl = '${AppConstants.supabaseStorageUrl}/$path';
      try {
        await supabaseServices.insertRow(
          table: AppTablesNames.stories,
          values: {
            'author_id': authorId,
            'image_url': imageUrl,
            'created_at': DateTime.now().toUtc().toIso8601String(),
            'is_private': isPrivate,
          },
        );
      } catch (dbError) {
        final errorStr = dbError.toString();
        if (errorStr.contains('is_private') || errorStr.contains('PGRST204')) {
          await supabaseServices.insertRow(
            table: AppTablesNames.stories,
            values: {
              'author_id': authorId,
              'image_url': imageUrl,
              'created_at': DateTime.now().toUtc().toIso8601String(),
            },
          );
          AppToast.showToast(
            msg: "Story uploaded. Note: Please add 'is_private' column to stories table in Supabase.",
            backgroundColor: AppColors.primaryColor,
          );
        } else {
          rethrow;
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
