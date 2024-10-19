// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'webview_screen.dart';
import 'user_info_screen.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/header_widget.dart'; // Import the Header widget

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  UserModel? _userInfo;
  List<ProjectModel>? _projects;
  List<UserModel>? _filteredUsers;

  @override
  void initState() {
    super.initState();
    _fetchUsersByCampus();
  }

  void _fetchUsersByCampus() async {
    final users = await _apiService.getUsersByCampus('urduliz');
    setState(() {
      _filteredUsers = users;
    });
  }

  void _login() async {
    final authorizationUrl = _authService.getAuthorizationUrl();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(
          initialUrl: authorizationUrl,
          onCodeReceived: (code) async {
            final accessToken = await _authService.exchangeCodeForToken(code);
            if (accessToken != null) {
              final loggedUserInfo = await _apiService.getLoggedUserInfo(); // Replace 0 with the actual userId
              Navigator.pop(context, {'userInfo': loggedUserInfo});
            }
          },
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _isLoggedIn = true;
        _userInfo = result['userInfo'];
        _projects = _userInfo?.projects;
      });
      await _authService.printAccessToken();
    }
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
      _userInfo = null;
      _projects = null;
    });
  }

  void _goToProfile() {
    if (_userInfo != null && _projects != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserInfoScreen(userInfo: _userInfo!, projects: _projects!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: 'Home Screen'), // Use the Header widget
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isLoggedIn)
              ElevatedButton(
                onPressed: _logout,
                child: const Text('Logout'),
              )
            else
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login with OAuth2'),
              ),
            if (_isLoggedIn)
              ElevatedButton(
                onPressed: _goToProfile,
                child: const Text('Go to My Profile'),
              ),
            if (_filteredUsers != null)
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredUsers!.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers![index];
                    return ListTile(
                      title: Text(user.usualFullName),
                      subtitle: Text(user.email),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}