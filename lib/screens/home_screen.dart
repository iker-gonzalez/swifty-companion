// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:swifty_companion/models/user_search_model.dart';
import 'webview_screen.dart';
import 'user_info_screen.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/header_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isInitialLogin = false;  // Add this flag to track initial login
  UserModel? _userInfo;
  List<UserSearchModel>? _usersByCampus;
  List<UserSearchModel>? _filteredUsers;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    setState(() => _isLoading = true);
    try {
      final isLoggedIn = await _authService.checkAccessToken();
      if (isLoggedIn) {
        _authService.printAccessToken();
        final userInfo = await _apiService.getLoggedUserInfo();
        setState(() {
          _isLoggedIn = true;
          _userInfo = userInfo;
        });

        if (_userInfo != null) {
          final campusName = _userInfo!.campus;
          await _fetchUsersByCampus(campusName);
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _login() async {
    final authorizationUrl = _authService.getAuthorizationUrl();
    setState(() => _isInitialLogin = true);  // Set flag before navigation

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
        _isLoading = true;  // Show loading while fetching users
      });

      // Update users by campus before navigating
      if (_userInfo != null) {
        await _fetchUsersByCampus(_userInfo!.campus);
      }

      // Navigate to UserInfoScreen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserInfoScreen(
            userId: _userInfo!.id,
            loggedInUserProfilePicture: _userInfo!.profilePicture,
          ),
        ),
      );

      // Reset flags after navigation
      if (mounted) {
        setState(() {
          _isInitialLogin = false;
          _isLoading = false;
        });
      }
    } else {
      // Reset flag if login was cancelled
      setState(() => _isInitialLogin = false);
    }
  }

  Future<void> _fetchUsersByCampus(String campusName) async {
    setState(() => _isLoading = true);
    try {
      final users = await _apiService.getUsersByCampus(campusName.toLowerCase());
      setState(() {
        _usersByCampus = users;
        _filteredUsers = users;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
      _isInitialLogin = false;
      _userInfo = null;
      _usersByCampus = null;
      _filteredUsers = null;
    });
  }

  void _goToProfile(int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserInfoScreen(
          userId: userId,
          loggedInUserProfilePicture: _userInfo?.profilePicture ?? '',
        ),
      ),
    );
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      _filteredUsers = _usersByCampus
          ?.where((user) => user.login.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: 'Home Screen',
        isLoggedIn: _isLoggedIn,
        profilePictureUrl: _userInfo?.profilePicture ?? '',
        onLogout: _logout,
        onGoToProfile: () => _goToProfile(_userInfo!.id),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (!_isLoggedIn)
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login with OAuth2'),
                  ),
                if (_isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                // Only show user list if not in initial login flow
                else if (_filteredUsers != null && !_isInitialLogin) ...[
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
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredUsers!.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers![index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(
                              user.login,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () => _goToProfile(user.id),
                          ),
                        );
                      },
                    ),
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