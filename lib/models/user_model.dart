// lib/models/user_model.dart
class UserModel {
  final String id;
  final String login;
  final String email;
  final String? phone;
  final double level;
  final String? location;
  final int wallet;
  final String profilePicture;
  final String firstName;
  final String lastName;
  final int correctionPoint;
  final String poolDate;

  UserModel({
    required this.id,
    required this.login,
    required this.email,
    this.phone,
    required this.level,
    this.location,
    required this.wallet,
    required this.profilePicture,
    required this.firstName,
    required this.lastName,
    required this.correctionPoint,
    required this.poolDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      login: json['login'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      level: (json['cursus_users'] as List?)?.isNotEmpty == true
          ? (json['cursus_users'][0]['level'] as num?)?.toDouble() ?? 0.0
          : 0.0,
      location: json['location'] as String?,
      wallet: json['wallet'] as int? ?? 0,
      profilePicture: json['image']?['link'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      correctionPoint: json['correction_point'] as int? ?? 0,
      poolDate: '${json['pool_year'] ?? ''}-${json['pool_month'] ?? ''}',
    );
  }
}