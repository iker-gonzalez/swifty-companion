// lib/screens/user_info_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../services/api_service.dart';
import '../widgets/header_widget.dart';

class UserInfoScreen extends StatefulWidget {
  final int userId;

  const UserInfoScreen({super.key, required this.userId});

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final ApiService _apiService = ApiService();
  UserModel? _userInfo;
  List<ProjectModel>? _projects;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  void _fetchUserInfo() async {
    final userInfo = await _apiService.getUserInfo(widget.userId);
    if (userInfo != null) {
      setState(() {
        _userInfo = userInfo;
        _projects = userInfo.projects;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: 'User Info', showBackButton: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userInfo == null
          ? const Center(child: Text('User not found'))
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(_userInfo!.profilePicture.isNotEmpty
                      ? _userInfo!.profilePicture
                      : 'https://via.placeholder.com/150'),
                ),
              ),
              const SizedBox(height: 16),
              Text('Full Name: ${_userInfo!.usualFullName}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Login: ${_userInfo!.login}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Email: ${_userInfo!.email}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Correction Points: ${_userInfo!.correctionPoint}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Level: ${_userInfo!.level}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Campus: ${_userInfo!.campus}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              const Text('Skills:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: _userInfo!.skills.length,
                  itemBuilder: (context, index) {
                    final skill = _userInfo!.skills[index];
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
                  itemCount: _projects!.length,
                  itemBuilder: (context, index) {
                    final project = _projects![index];
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