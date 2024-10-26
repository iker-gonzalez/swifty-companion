// lib/screens/user_info_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/cursus_model.dart';
import '../models/skill_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/header_widget.dart';
import 'home_screen.dart';

class UserInfoScreen extends StatefulWidget {
  final int userId;
  final String loggedInUserProfilePicture;
  final int loggedInUserId;

  const UserInfoScreen({
    super.key,
    required this.userId,
    required this.loggedInUserProfilePicture,
    required this.loggedInUserId,
  });

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  UserModel? _userInfo;
  Cursus? _selectedCursus;
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
        _selectedCursus = userInfo.cursus.isNotEmpty ? userInfo.cursus[0] : null;
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    await _authService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
    );
  }

  void _goToProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => UserInfoScreen(
          userId: widget.loggedInUserId,
          loggedInUserProfilePicture: widget.loggedInUserProfilePicture,
          loggedInUserId: widget.loggedInUserId,
        ),
      ),
    );
  }

  double _calculateLevelProgress(double level, double maxLevel) {
    int currentLevel = level.floor();
    double progress = level - currentLevel;
    return (currentLevel + progress) / maxLevel;
  }

  double _getMaxLevel(String cursusName) {
    if (cursusName == '42cursus') return 21.0;
    if (cursusName == 'C Piscine') return 11.0;
    if (cursusName == 'Discovery Piscine - Web') return 15.0;
    return 1.0;
  }

  Color _getSkillColor(double level) {
    if (level >= 10) return Colors.green;
    if (level >= 5) return Colors.orange;
    return Colors.red;
  }

  Widget _buildSkillCard(SkillModel skill) {
    return Card(
      color: _getSkillColor(skill.level),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    skill.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level: ${skill.level.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: 'User Info',
        showBackButton: true,
        isLoggedIn: true,
        profilePictureUrl: widget.loggedInUserProfilePicture,
        onLogout: _logout,
        onGoToProfile: _goToProfile,
      ),
      body: Container(
        color: Colors.grey[200],
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _userInfo == null
            ? const Center(child: Text('User not found'))
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_userInfo!.profilePicture.isNotEmpty
                        ? _userInfo!.profilePicture
                        : 'https://via.placeholder.com/150'),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    _userInfo!.usualFullName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _userInfo!.login,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text('Email: ${_userInfo!.email}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Correction Points: ${_userInfo!.correctionPoint}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Campus: ${_userInfo!.campus}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text('Cursus:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                DropdownButton<Cursus>(
                  value: _selectedCursus,
                  onChanged: (Cursus? newValue) {
                    setState(() {
                      _selectedCursus = newValue;
                    });
                  },
                  items: _userInfo!.cursus.map<DropdownMenuItem<Cursus>>((Cursus cursus) {
                    return DropdownMenuItem<Cursus>(
                      value: cursus,
                      child: Text(cursus.name),
                    );
                  }).toList(),
                ),
                if (_selectedCursus != null) ...[
                  const SizedBox(height: 16),
                  Text('Level: ${_selectedCursus!.level.floor()}', style: const TextStyle(fontSize: 18)),
                  LinearProgressIndicator(
                    value: _calculateLevelProgress(_selectedCursus!.level, _getMaxLevel(_selectedCursus!.name)),
                    backgroundColor: Colors.grey[300],
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  const Text('Skills:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _selectedCursus!.skills.length,
                        itemBuilder: (context, index) {
                          return _buildSkillCard(_selectedCursus!.skills[index]);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Projects:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _selectedCursus!.projects
                        .where((project) => project.validated || project.status == 'finished')
                        .length,
                    itemBuilder: (context, index) {
                      final project = _selectedCursus!.projects
                          .where((project) => project.validated || project.status == 'finished')
                          .toList()[index];
                      return Card(
                        child: ListTile(
                          title: Text(project.name),
                          subtitle: Text('Final Mark: ${project.finalMark ?? 'N/A'}'),
                          trailing: project.validated
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.cancel, color: Colors.red),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}