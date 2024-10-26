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
  UserModel? _userInfo;
  List<UserSearchModel>? _usersByCampus;
  List<UserSearchModel>? _filteredUsers;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _authService.checkAccessToken().then((isLoggedIn) {
      if (isLoggedIn) {
        _authService.printAccessToken();
        _apiService.getLoggedUserInfo().then((userInfo) {
          setState(() {
            _isLoggedIn = true;
            _userInfo = userInfo;
          });

          // Fetch users by campus
          if (_userInfo != null) {
            final campusName = _userInfo!.campus;
            _fetchUsersByCampus(campusName);
          }
        });
      }
    });
  }

  void _fetchUsersByCampus(String campusName) async {
    final users = await _apiService.getUsersByCampus(campusName.toLowerCase());
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
      });

      // Fetch users by campus
      if (_userInfo != null) {
        final campusName = _userInfo!.campus;
        _fetchUsersByCampus(campusName);
      }
    }
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
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
                if (_filteredUsers != null) ...[
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
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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