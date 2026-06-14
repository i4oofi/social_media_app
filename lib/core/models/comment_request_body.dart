// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CommentRequestBody {
  final String authorId;
  final String text;
  final String postId;
  final String? image;
  final String? parentId;

  CommentRequestBody({
    required this.authorId,
    required this.text,
    required this.postId,
    this.image,
    this.parentId,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'author_id': authorId,
      'text': text,
      'post_id': postId,
    };
    if (image != null) map['image'] = image;
    if (parentId != null) map['parent_id'] = parentId;
    return map;
  }

  factory CommentRequestBody.fromMap(Map<String, dynamic> map) {
    return CommentRequestBody(
      authorId: map['author_id'] as String,
      text: map['text'] as String,
      postId: map['post_id'] as String,
      image: map['image'] != null ? map['image'] as String : null,
      parentId: map['parent_id'] != null ? map['parent_id'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CommentRequestBody.fromJson(String source) => CommentRequestBody.fromMap(json.decode(source) as Map<String, dynamic>);
}
