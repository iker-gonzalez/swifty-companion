// lib/models/user_model.dart
import 'project_model.dart';
import 'skill_model.dart';
import 'cursus_model.dart';

class UserModel {
  final int id;
  final String login;
  final String email;
  final String usualFullName;
  final String profilePicture;
  final String campus;
  final int correctionPoint;
  final List<Cursus> cursus;
  final List<ProjectModel> projects;

  UserModel({
    required this.id,
    required this.login,
    required this.email,
    required this.usualFullName,
    required this.profilePicture,
    required this.campus,
    required this.correctionPoint,
    required this.cursus,
    required this.projects,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final cursusList = (json['cursus_users'] as List<dynamic>?)?.map((cursus) {
      return Cursus.fromJson(cursus);
    }).toList() ?? [];

    final projectsList = (json['projects_users'] as List<dynamic>?)?.map((project) {
      return ProjectModel.fromJson(project);
    }).toList() ?? [];

    final campus = (json['campus'] as List<dynamic>?)?.isNotEmpty == true
        ? json['campus']![0]['name'] as String? ?? ''
        : '';

    final userModel = UserModel(
      id: json['id'] as int? ?? 0,
      login: json['login'] as String? ?? '',
      email: json['email'] as String? ?? '',
      usualFullName: json['usual_full_name'] as String? ?? '',
      profilePicture: json['image']?['link'] as String? ?? '',
      campus: campus,
      correctionPoint: json['correction_point'] as int? ?? 0,
      cursus: cursusList,
      projects: projectsList,
    );

    for (var cursus in userModel.cursus) {
      cursus.setProjects(userModel.projects);
    }

    return userModel;
  }
}