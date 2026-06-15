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
  final bool isPrivate;
  final bool isReel;
  final bool? isFollowingAuthor;

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
    this.isPrivate = false,
    this.isReel = false,
    this.isFollowingAuthor,
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
      'is_private': isPrivate,
      'is_reel': isReel,
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
      isPrivate: map['is_private'] != null ? map['is_private'] as bool : false,
      isReel: map['is_reel'] != null ? map['is_reel'] as bool : false,
      isFollowingAuthor: map['is_following_author'] != null ? map['is_following_author'] as bool : null,
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
    bool? isPrivate,
    bool? isReel,
    bool? isFollowingAuthor,
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
      isPrivate: isPrivate ?? this.isPrivate,
      isReel: isReel ?? this.isReel,
      isFollowingAuthor: isFollowingAuthor ?? this.isFollowingAuthor,
    );
  }
}
