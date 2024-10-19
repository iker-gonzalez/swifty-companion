// lib/models/project_model.dart
class ProjectModel {
  final int id;
  final String name;
  final String status;
  final int? finalMark;
  final List<int> cursusIds;

  ProjectModel({
    required this.id,
    required this.name,
    required this.status,
    this.finalMark,
    required this.cursusIds,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['project']['id'] as int,
      name: json['project']['name'] as String,
      status: json['status'] as String,
      finalMark: json['final_mark'] as int?,
      cursusIds: (json['cursus_ids'] as List<dynamic>).map((id) => id as int).toList(),
    );
  }
}