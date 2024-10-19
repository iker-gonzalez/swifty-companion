// lib/models/user_model.dart
import 'project_model.dart';
import 'skill_model.dart';

class UserModel {
  final int id;
  final String login;
  final String email;
  final String usualFullName;
  final String profilePicture;
  final String campus;
  final int correctionPoint;
  final double level;
  final List<SkillModel> skills;
  final List<ProjectModel> projects;

  UserModel({
    required this.id,
    required this.login,
    required this.email,
    required this.usualFullName,
    required this.profilePicture,
    required this.campus,
    required this.correctionPoint,
    required this.level,
    required this.skills,
    required this.projects,
// Initialize campus attribute
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final memberCursus = (json['cursus_users'] as List<dynamic>).firstWhere(
          (cursus) => cursus['grade'] == 'Member',
      orElse: () => null,
    );

    final skills = memberCursus != null
        ? (memberCursus['skills'] as List<dynamic>).map((skill) {
      return SkillModel.fromJson(skill);
    }).toList()
        : <SkillModel>[];

    final projects = (json['projects_users'] as List<dynamic>).map((project) {
      return ProjectModel.fromJson(project);
    }).toList();

    final campus = (json['campus'] as List<dynamic>).isNotEmpty
        ? json['campus'][0]['name'] as String? ?? ''
        : '';

    return UserModel(
      id: json['id'] as int? ?? 0,
      login: json['login'] as String? ?? '',
      email: json['email'] as String? ?? '',
      usualFullName: json['usual_full_name'] as String? ?? '',
      profilePicture: json['image']?['link'] as String? ?? '',
      campus: campus,
      correctionPoint: json['correction_point'] as int? ?? 0,
      level: memberCursus != null ? (memberCursus['level'] as num?)?.toDouble() ?? 0.0 : 0.0,
      skills: skills,
      projects: projects,
    );
  }
}