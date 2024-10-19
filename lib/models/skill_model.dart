// lib/models/skill_model.dart
class SkillModel {
  final String name;
  final double level;

  SkillModel({
    required this.name,
    required this.level,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      name: json['name'] as String? ?? '',
      level: (json['level'] as num?)?.toDouble() ?? 0.0,
    );
  }
}