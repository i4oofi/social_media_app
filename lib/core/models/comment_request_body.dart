// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CommentRequestBody {
  final String authorId;
  final String text;
  final String postId;
  final String? image;

  CommentRequestBody({
    required this.authorId,
    required this.text,
    required this.postId,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'author_id': authorId,
      'text': text,
      'post_id': postId,
      'image': image,
    };
  }

  factory CommentRequestBody.fromMap(Map<String, dynamic> map) {
    return CommentRequestBody(
      authorId: map['author_id'] as String,
      text: map['text'] as String,
      postId: map['post_id'] as String,
      image: map['image'] != null ? map['image'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CommentRequestBody.fromJson(String source) => CommentRequestBody.fromMap(json.decode(source) as Map<String, dynamic>);
}
