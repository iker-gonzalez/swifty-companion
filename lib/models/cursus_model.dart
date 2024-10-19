// lib/models/cursus_model.dart
import 'skill_model.dart';
import 'project_model.dart';

class Cursus {
  final int id;
  final String name;
  final double level;
  final List<SkillModel> skills;
  List<ProjectModel> projects = [];

  Cursus({
    required this.id,
    required this.name,
    required this.level,
    required this.skills,
  });

  factory Cursus.fromJson(Map<String, dynamic> json) {
    final skills = (json['skills'] as List<dynamic>?)?.map((skill) {
      return SkillModel.fromJson(skill);
    }).toList() ?? [];

    return Cursus(
      id: json['cursus_id'] as int? ?? 0,
      name: json['cursus']['name'] as String? ?? '',
      level: (json['level'] as num?)?.toDouble() ?? 0.0,
      skills: skills,
    );
  }

  void setProjects(List<ProjectModel> allProjects) {
    projects = allProjects.where((project) => project.cursusIds.contains(id)).toList();
  }
}