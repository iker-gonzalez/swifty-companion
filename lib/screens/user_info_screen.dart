// lib/screens/user_info_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/cursus_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/header_widget.dart';
import 'home_screen.dart';

class UserInfoScreen extends StatefulWidget {
  final int userId;
  final String loggedInUserProfilePicture;
  final int loggedInUserId; // Add this field

  const UserInfoScreen({
    super.key,
    required this.userId,
    required this.loggedInUserProfilePicture,
    required this.loggedInUserId, // Add this field
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
          userId: widget.loggedInUserId, // Use logged-in user's ID
          loggedInUserProfilePicture: widget.loggedInUserProfilePicture,
          loggedInUserId: widget.loggedInUserId, // Pass logged-in user's ID
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
        color: Colors.grey[200], // Match background color with HomeScreen
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
                const SizedBox(height: 16),
                if (_selectedCursus != null) ...[
                  Text('Level: ${_selectedCursus!.level}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  const Text('Skills:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _selectedCursus!.skills.length,
                    itemBuilder: (context, index) {
                      final skill = _selectedCursus!.skills[index];
                      return ListTile(
                        title: Text(skill.name),
                        subtitle: Text('Level: ${skill.level}'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Projects:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _selectedCursus!.projects.length,
                    itemBuilder: (context, index) {
                      final project = _selectedCursus!.projects[index];
                      return ListTile(
                        title: Text(project.name),
                        subtitle: Text('Status: ${project.status}, Final Mark: ${project.finalMark ?? 'N/A'}'),
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