import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/cubit/posts_cubit/posts_cubit.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/features/home/widgets/comment_section.dart';
import 'package:social_media_app/features/home/widgets/like_section.dart';
import 'package:social_media_app/features/home/widgets/send_comment_section.dart';

class CommentsSheet extends StatefulWidget {
  final PostModel post;
  const CommentsSheet({super.key, required this.post});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  late PostsCubit postsCubit;

  @override
  void initState() {
    postsCubit = context.read<PostsCubit>();
    postsCubit.fetchPostLikesDetails(widget.post.id);
    postsCubit.fetchComments(widget.post.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            flex: 10,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SizedBox(
                      height: 10,
                      width: 50,
                      child: Divider(color: Colors.grey, thickness: 2),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Likes', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 8),
                  LikeSection(post: widget.post),
                  SizedBox(height: 16),
                  Text(
                    'Comments',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  CommentSection(post: widget.post),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SendCommentSection(post: widget.post),
          ),
        ],
      ),
    );
  }
}
