// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserData {
  final String id;
  final String name;
  final String userName;
  final String? title;
  final String? imageUrl;
  final String email;

  UserData({
    required this.id,
    required this.name,
    required this.userName,
    this.title,
    this.imageUrl,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'userName': userName,
      'title': title,
      'imageUrl': imageUrl,
      'email': email,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'] as String,
      name: map['name'] as String,
      userName: map['userName'] as String,
      title: map['title'] != null ? map['title'] as String : null,
      imageUrl: map['imageUrl'] != null ? map['imageUrl'] as String : null,
      email: map['email'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserData.fromJson(String source) => UserData.fromMap(json.decode(source) as Map<String, dynamic>);

  UserData copyWith({
    String? id,
    String? name,
    String? userName,
    String? title,
    String? imageUrl,
    String? email,
  }) {
    return UserData(
      id: id ?? this.id,
      name: name ?? this.name,
      userName: userName ?? this.userName,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      email: email ?? this.email,
    );
  }
}
