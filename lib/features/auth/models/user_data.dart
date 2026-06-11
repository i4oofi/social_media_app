// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserData {
  final String id;
  final String name;
  final String? title;
  final String? imageUrl;
  final String? coverUrl;
  final String email;
  final num? postsCount;
  final num? followersCount;
  final num? followingCount;
  final List<String>? followers;
  final List<String>? following;

  UserData({
    required this.id,
    required this.name,
    this.title,
    this.imageUrl,
    this.coverUrl,
    required this.email,
    this.postsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.followers = const [],
    this.following = const [],
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'title': title,
      'image_url': imageUrl,
      'cover_url': coverUrl,
      'email': email,
      'followers_count': followersCount,
      'following_count': followingCount,
      'followers': followers,
      'following': following,
    };
  }


  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'] as String,
      name: map['name'] as String,
      title: map['title'] != null ? map['title'] as String : null,
      imageUrl: map['image_url'] != null ? map['image_url'] as String : null,
      coverUrl: map['cover_url'] != null ? map['cover_url'] as String : null,
      email: map['email'] as String,
      followersCount: map['followers_count'] != null
          ? map['followers_count'] as int
          : 0,
      followingCount: map['following_count'] != null
          ? map['following_count'] as int
          : 0,
      followers: map['followers'] != null
          ? List<String>.from(map['followers'] as List<dynamic>)
          : [],
      following: map['following'] != null
          ? List<String>.from(map['following'] as List<dynamic>)
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserData.fromJson(String source) =>
      UserData.fromMap(json.decode(source) as Map<String, dynamic>);

  UserData copyWith({
    String? id,
    String? name,
    String? userName,
    String? title,
    String? imageUrl,
    String? coverUrl,
    String? email,
    num? postsCount,
    num? followersCount,
    num? followingCount,
    List<String>? followers,
    List<String>? following,
  }) {
    return UserData(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      email: email ?? this.email,
      postsCount: postsCount ?? this.postsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }
}
