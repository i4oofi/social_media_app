// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CommentModel {
  final String id;
  final String createdAt;
  final String authorId;
  final String text;
  final String postId;
  final String? image;
  final String? authorName;
  final String? authorImage;
  final List<String>? likes;
  final bool isLiked;
  final String? parentId;

  CommentModel({
    required this.id,
    required this.createdAt,
    required this.authorId,
    required this.text,
    required this.postId,
    this.authorName,
    this.authorImage,
    this.image,
    this.likes,
    this.isLiked = false,
    this.parentId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt,
      'author_id': authorId,
      'text': text,
      'post_id': postId,
      'image': image,
      'likes': likes,
      'parent_id': parentId,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as String,
      createdAt: map['created_at'] as String,
      authorId: map['author_id'] as String,
      text: map['text'] as String,
      postId: map['post_id'] as String,
      image: map['image'] as String?,
      likes: map['likes'] != null ? List<String>.from(map['likes'] as List) : null,
      parentId: map['parent_id'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory CommentModel.fromJson(String source) =>
      CommentModel.fromMap(json.decode(source) as Map<String, dynamic>);

  CommentModel copyWith({
    String? id,
    String? createdAt,
    String? authorId,
    String? text,
    String? postId,
    String? image,
    String? authorName,
    String? authorImage,
    List<String>? likes,
    bool? isLiked,
    String? parentId,
  }) {
    return CommentModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      authorId: authorId ?? this.authorId,
      text: text ?? this.text,
      postId: postId ?? this.postId,
      image: image ?? this.image,
      authorName: authorName ?? this.authorName,
      authorImage: authorImage ?? this.authorImage,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      parentId: parentId ?? this.parentId,
    );
  }
}
