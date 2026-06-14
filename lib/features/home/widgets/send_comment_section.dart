import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/cubit/posts_cubit/posts_cubit.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/core/shared/widgets/app_toast.dart';
import 'package:social_media_app/core/theme/app_colors.dart';

class SendCommentSection extends StatefulWidget {
  final PostModel post;
  const SendCommentSection({super.key, required this.post});

  @override
  State<SendCommentSection> createState() => _SendCommentSectionState();
}

class _SendCommentSectionState extends State<SendCommentSection> {
  final textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final postsCubit = context.read<PostsCubit>();
    return BlocBuilder<PostsCubit, PostsState>(
      buildWhen: (previous, current) => current is ReplyingToComment,
      builder: (context, state) {
        final replyingTo = postsCubit.replyingToComment;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (replyingTo != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.babyBlue5.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Replying to ${replyingTo.authorName ?? "Anonymous"}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => postsCubit.setReplyingTo(null),
                      child: const Icon(Icons.close, size: 16),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                BlocConsumer<PostsCubit, PostsState>(
                  buildWhen: (previous, current) =>
                      current is CommentAdded ||
                      current is CommentAdding ||
                      current is CommentAddingError,
                  bloc: postsCubit,
                  listenWhen: (previous, current) =>
                      current is CommentAdded || current is CommentAddingError,
                  listener: (context, state) async {
                    if (state is CommentAdded) {
                      textController.clear();
                      postsCubit.setReplyingTo(null);
                      await postsCubit.fetchComments(widget.post.id);
                    } else if (state is CommentAddingError) {
                      AppToast.showToast(
                        msg: state.error,
                        backgroundColor: AppColors.red,
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is CommentAdding) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: CircularProgressIndicator(),
                      );
                    }
                    return IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        if (textController.text.trim().isEmpty) return;
                        await postsCubit.addComment(
                          widget.post.id,
                          textController.text.trim(),
                          parentId: postsCubit.replyingToComment?.parentId ?? postsCubit.replyingToComment?.id,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
