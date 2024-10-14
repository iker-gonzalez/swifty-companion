import 'package:flutter/material.dart';
import 'webview_screen.dart';
import 'user_info_screen.dart';
import '../models/user_model.dart';
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
              final userInfo = await _apiService.getUserInfo();
              if (userInfo != null) {
                Navigator.pop(context, userInfo);
              }
            }
          },
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _isLoggedIn = true;
        _userInfo = result;
      });
    }
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
      _userInfo = null;
    });
  }

  void _goToProfile() {
    if (_userInfo != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserInfoScreen(userInfo: _userInfo!),
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
          ],
        ),
      ),
    );
  }
}