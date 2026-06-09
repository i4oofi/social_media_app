// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PostModel {
  final String id;
  final String text;
  final String authorId;
  final String? imageUrl;
  final String? video;
  final String? authorName;
  final String? authorProfileImage;
  final String createdAt;
  final List<String>? likes;
  final int? commentCount;
  final bool isLiked;

  const PostModel({
    required this.id,
    required this.text,
    required this.authorId,
    this.imageUrl,
    this.video,
    this.authorName,
    this.authorProfileImage,
    required this.createdAt,
    this.likes,
    this.commentCount = 0,
    this.isLiked = false,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'author_id': authorId,
      'image_url': imageUrl,
      'video': video,
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
      video: map['video'] as String?,
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
      commentCount: map['comments'] != null
          ? map['comments'] as int
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
    String? video,
    String? authorName,
    String? authorProfileImage,
    String? createdAt,
    List<String>? likes,
    int? commentCount,
    bool? isLiked,
  }) {
    return PostModel(
      id: id ?? this.id,
      text: text ?? this.text,
      authorId: authorId ?? this.authorId,
      imageUrl: imageUrl ?? this.imageUrl,
      video: video ?? this.video,
      authorName: authorName ?? this.authorName,
      authorProfileImage: authorProfileImage ?? this.authorProfileImage,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
