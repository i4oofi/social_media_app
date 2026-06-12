// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class StoryModel {
  final String imageUrl;
  final String authorId;
  final String id;
  final String createdAt;
  final String authorName;
  final String? authorProfileImage;
  final bool isPrivate;

  StoryModel({
    required this.imageUrl,
    required this.authorId,
    required this.id,
    required this.createdAt,
    this.authorName = '',
    this.authorProfileImage,
    this.isPrivate = false,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'image_url': imageUrl,
      'author_id': authorId,
      'id': id,
      'created_at': createdAt,
      'is_private': isPrivate,
    };
  }

  factory StoryModel.fromMap(Map<String, dynamic> map) {
    return StoryModel(
      imageUrl: map['image_url'] as String,
      authorId: map['author_id'] as String,
      id: map['id'] as String,
      createdAt: map['created_at'] as String,
      isPrivate: map['is_private'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory StoryModel.fromJson(String source) =>
      StoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  StoryModel copyWith({
    String? imageUrl,
    String? authorId,
    String? id,
    String? createdAt,
    String? authorName,
    String? authorProfileImage,
    bool? isPrivate,
  }) {
    return StoryModel(
      imageUrl: imageUrl ?? this.imageUrl,
      authorId: authorId ?? this.authorId,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      authorName: authorName ?? this.authorName,
      authorProfileImage: authorProfileImage ?? this.authorProfileImage,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}
