import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'webview_screen.dart';
import 'user_info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserInfoScreen(userInfo: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _login,
          child: const Text('Login with OAuth2'),
        ),
      ),
    );
  }
}