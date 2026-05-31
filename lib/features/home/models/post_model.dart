// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PostModel {
  final String id;
  final String text;
  final String authorId;
  final String? imageUrl;
  final String? authorName;
  final String? authorProfileImage;
  final String createdAt;
  final List<String>? likes;
  final List<String>? comments;
  final bool isLiked;

  const PostModel({
    required this.id,
    required this.text,
    required this.authorId,
    this.imageUrl,
    this.authorName,
    this.authorProfileImage,
    required this.createdAt,
    this.likes,
    this.comments,
    this.isLiked = false,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'author_id': authorId,
      'image_url': imageUrl,
      'created_at': createdAt,
      'likes': likes,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] as String,
      text: map['text'] as String,
      authorId: map['author_id'] as String,
      imageUrl: map['image_url'] as String?,
      authorName: map['author_name'] != null
          ? map['author_name'] as String
          : null,
      // authorProfileImage: map['author_image_url'] != null
      //     ? map['author_image_url'] as String
      //     : null,
      createdAt: map['created_at'] as String,
      likes: map['likes'] != null
          ? List<String>.from(map['likes'] as List)
          : null,
      comments: map['comments'] != null
          ? List<String>.from(map['comments'] as List)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PostModel.fromJson(String source) =>
      PostModel.fromMap(json.decode(source) as Map<String, dynamic>);

  PostModel copyWith({
    String? id,
    String? text,
    String? authorId,
    String? imageUrl,
    String? authorName,
    String? authorProfileImage,
    String? createdAt,
    List<String>? likes,
    List<String>? comments,
    bool? isLiked,
  }) {
    return PostModel(
      id: id ?? this.id,
      text: text ?? this.text,
      authorId: authorId ?? this.authorId,
      imageUrl: imageUrl ?? this.imageUrl,
      authorName: authorName ?? this.authorName,
      authorProfileImage: authorProfileImage ?? this.authorProfileImage,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
