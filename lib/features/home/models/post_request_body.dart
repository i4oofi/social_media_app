// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

class PostRequestBody {
  final String text;
  final String authorId;
  final File? image;
  final File? file;
  PostRequestBody({
    required this.text,
    required this.authorId,
    this.image,
    this.file,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'text': text,
      'author_id': authorId,
      'image_url': image != null
          ? base64Encode(image!.readAsBytesSync())
          : null,
      'file': file != null ? base64Encode(file!.readAsBytesSync()) : null,
    };
  }

  String toJson() => json.encode(toMap());
}
