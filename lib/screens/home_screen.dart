// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'webview_screen.dart';
import 'user_info_screen.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/header_widget.dart';

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
  List<UserModel>? _usersByCampus;
  List<UserModel>? _filteredUsers;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUsersByCampus();
  }

  void _fetchUsersByCampus() async {
    final users = await _apiService.getUsersByCampus('urduliz');
    setState(() {
      _usersByCampus = users;
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
              final loggedUserInfo = await _apiService.getLoggedUserInfo();
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

      // Fetch users by campus
      if (_userInfo != null) {
        final campusName = _userInfo!.campus;
        final users = await _apiService.getUsersByCampus(campusName);
        setState(() {
          _usersByCampus = users;
          _filteredUsers = users;
        });
      }
    }
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
      _userInfo = null;
      _projects = null;
      _usersByCampus = null;
      _filteredUsers = null;
    });
  }

  void _goToProfile(int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserInfoScreen(userId: userId),
      ),
    );
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      _filteredUsers = _usersByCampus?.where((user) {
        return user.login.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: 'Home Screen'),
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
                onPressed: () => _goToProfile(_userInfo!.id),
                child: const Text('Go to My Profile'),
              ),
            if (_filteredUsers != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search by login',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _filterUsers,
                ),
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
                      onTap: () => _goToProfile(user.id),
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