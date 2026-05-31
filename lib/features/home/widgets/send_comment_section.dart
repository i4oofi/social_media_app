import 'package:flutter/material.dart';
import 'package:social_media_app/features/home/models/post_model.dart';

class SendCommentSection extends StatelessWidget {
  final PostModel post;
  const SendCommentSection({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return  TextField(
      decoration: InputDecoration(
        hintText: "Add a comment...",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}