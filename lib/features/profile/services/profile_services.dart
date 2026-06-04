import 'package:social_media_app/core/models/comment_model.dart';
import 'package:social_media_app/core/services/supabase_database_services.dart';
import 'package:social_media_app/core/theme/app_tables_names.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileServices {
  final supabaseServices = SupabaseDatabaseServices.instance;
  final supabaseStorageClient = Supabase.instance.client.storage;

  Future<List<PostModel>> fetchUserPosts(String userId) async {
    try {
      return await supabaseServices.fetchRows(
        table: AppTablesNames.posts,
        builder: (data, id) {
          return PostModel.fromMap(data);
        },
        primaryKey: 'id',
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
}
