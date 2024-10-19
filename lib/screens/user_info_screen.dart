// lib/screens/user_info_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../widgets/header_widget.dart';

class UserInfoScreen extends StatelessWidget {
  final UserModel userInfo;
  final List<ProjectModel> projects;

  const UserInfoScreen({super.key, required this.userInfo, required this.projects});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: 'User Info', showBackButton: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Align to the top
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16.0), // Add top margin
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(userInfo.profilePicture.isNotEmpty
                      ? userInfo.profilePicture
                      : 'https://via.placeholder.com/150'),
                ),
              ),
              const SizedBox(height: 16),
              Text('Full Name: ${userInfo.usualFullName}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Login: ${userInfo.login}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Email: ${userInfo.email}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Correction Points: ${userInfo.correctionPoint}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Level: ${userInfo.level}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              const Text('Skills:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: userInfo.skills.length,
                  itemBuilder: (context, index) {
                    final skill = userInfo.skills[index];
                    return ListTile(
                      title: Text(skill.name),
                      subtitle: Text('Level: ${skill.level}'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Text('Projects:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return ListTile(
                      title: Text(project.name),
                      subtitle: Text('Status: ${project.status}, Final Mark: ${project.finalMark}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}