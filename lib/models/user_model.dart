// lib/models/user_model.dart
class UserModel {
  final String id;
  final String login;
  final String email;

  UserModel({required this.id, required this.login, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(), // Convert to String if necessary
      login: json['login'] as String,
      email: json['email'] as String,
    );
  }
}