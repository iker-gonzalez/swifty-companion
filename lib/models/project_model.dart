// lib/models/project_model.dart
class ProjectModel {
final String name;
final String status;
final String? finalMark;

ProjectModel({
required this.name,
required this.status,
this.finalMark,
});

factory ProjectModel.fromJson(Map<String, dynamic> json) {
return ProjectModel(
name: json['project']['name'] as String,
status: json['status'] as String,
finalMark: json['final_mark']?.toString(),
);
}
}