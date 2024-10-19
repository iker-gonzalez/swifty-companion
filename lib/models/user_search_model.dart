// lib/models/user_search_model.dart
class UserSearchModel {
  final int id;
  final String login;
  final String profilePicture;

  UserSearchModel({
    required this.id,
    required this.login,
    required this.profilePicture,
  });

  factory UserSearchModel.fromJson(Map<String, dynamic> json) {
    return UserSearchModel(
      id: json['id'] as int,
      login: json['login'] as String,
      profilePicture: json['image']['link'] as String,
    );
  }

  @override
  String toString() {
    return 'UserSearchModel{id: $id, login: $login, profilePicture: $profilePicture}';
  }
}