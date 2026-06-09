// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PostRequestBody {
  final String text;
  final String authorId;
  final String? imageUrl;
  final String? video;
  final String? file;
  PostRequestBody({
    required this.text,
    required this.authorId,
    this.imageUrl,
    this.video,
    this.file,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'text': text,
      'author_id': authorId,
      'image_url': imageUrl,
      'video': video,
      'file': file,
    };
  }

  String toJson() => json.encode(toMap());

  PostRequestBody copyWith({
    String? text,
    String? authorId,
    String? imageUrl,
    String? video,
    String? file,
  }) {
    return PostRequestBody(
      text: text ?? this.text,
      authorId: authorId ?? this.authorId,
      imageUrl: imageUrl ?? this.imageUrl,
      video: video ?? this.video,
      file: file ?? this.file,
    );
  }
}
