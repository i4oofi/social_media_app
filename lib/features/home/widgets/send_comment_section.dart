import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/cubit/posts_cubit.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';
import 'package:social_media_app/features/home/models/post_model.dart';

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
    return Row(
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
              await postsCubit.fetchComments(widget.post.id);
            } else if (state is CommentAddingError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
          builder: (context, state) {
            if (state is CommentAdding) {
              return const CircularProgressIndicator();
            }
            return IconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                await postsCubit.addComment(widget.post.id, textController.text);
              },
            );
          },
        ),
      ],
    );
  }
}
