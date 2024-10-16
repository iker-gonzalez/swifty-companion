// lib/models/user_model.dart
class UserModel {
  final int id;
  final String login;
  final String email;
  final double level;
  final int wallet;
  final String profilePicture;
  final String firstName;
  final String lastName;

  UserModel({
    required this.id,
    required this.login,
    required this.email,
    required this.level,
    required this.wallet,
    required this.profilePicture,
    required this.firstName,
    required this.lastName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      login: json['login'] as String? ?? '',
      email: json['email'] as String? ?? '',
      level: (json['cursus_users'] as List?)?.isNotEmpty == true
          ? (json['cursus_users'][0]['level'] as num?)?.toDouble() ?? 0.0
          : 0.0,
      wallet: json['wallet'] as int? ?? 0,
      profilePicture: json['image']?['link'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
    );
  }
}