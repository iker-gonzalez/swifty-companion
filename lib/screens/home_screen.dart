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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Services
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  // State variables
  late bool _isLoggedIn;
  late bool _isLoading;
  late bool _isInitialLogin;
  UserModel? _userInfo;
  List<UserSearchModel>? _usersByCampus;
  List<UserSearchModel>? _filteredUsers;

  @override
  void initState() {
    super.initState();
    _initializeState();
    _checkLoginStatus();
  }

  void _initializeState() {
    _isLoggedIn = false;
    _isLoading = false;
    _isInitialLogin = false;
    _userInfo = null;
    _usersByCampus = null;
    _filteredUsers = null;
  }

  Future<void> _checkLoginStatus() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final isLoggedIn = await _authService.checkAccessToken();
      if (isLoggedIn && mounted) {
        _authService.printAccessToken();
        final userInfo = await _apiService.getLoggedUserInfo();

        if (!mounted) return;

        setState(() {
          _isLoggedIn = true;
          _userInfo = userInfo;
        });

        if (_userInfo != null) {
          await _fetchUsersByCampus(_userInfo!.campus);
        }
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _login() async {
    if (!mounted) return;

    final authorizationUrl = _authService.getAuthorizationUrl();
    setState(() => _isInitialLogin = true);

    try {
      final result = await _handleWebViewNavigation(authorizationUrl);
      if (!mounted) return;

      if (result != null) {
        await _handleSuccessfulLogin(result);
      }
    } catch (e) {
      debugPrint('Error during login: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLogin = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _handleWebViewNavigation(String authorizationUrl) {
    return Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => WebViewPage(
          initialUrl: authorizationUrl,
          onCodeReceived: _handleCodeReceived,
        ),
      ),
    );
  }

  Future<void> _handleCodeReceived(String code) async {
    final accessToken = await _authService.exchangeCodeForToken(code);
    if (accessToken != null) {
      final loggedUserInfo = await _apiService.getLoggedUserInfo();
      if (!mounted) return;
      Navigator.of(context).pop({'userInfo': loggedUserInfo});
    }
  }

  Future<void> _handleSuccessfulLogin(Map<String, dynamic> result) async {
    setState(() {
      _isLoggedIn = true;
      _userInfo = result['userInfo'];
      _isLoading = true;
    });

    if (_userInfo != null) {
      await _fetchUsersByCampus(_userInfo!.campus);
    }

    if (!mounted) return;

    await _navigateToUserInfoScreen();

    if (!mounted) return;

    setState(() {
      _isInitialLogin = false;
      _isLoading = false;
    });
  }

  Future<void> _navigateToUserInfoScreen() {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserInfoScreen(
          userId: _userInfo!.id,
          loggedInUserProfilePicture: _userInfo!.profilePicture,
          loggedInUserId: _userInfo!.id,
        ),
      ),
    );
  }

  Future<void> _fetchUsersByCampus(String campusName) async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final users = await _apiService.getUsersByCampus(campusName.toLowerCase());
      if (!mounted) return;

      setState(() {
        _usersByCampus = users;
        _filteredUsers = users;
      });
    } catch (e) {
      debugPrint('Error fetching users by campus: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserInfoScreen(
          userId: userId,
          loggedInUserProfilePicture: _userInfo?.profilePicture ?? '',
          loggedInUserId: _userInfo?.id ?? 0,
        ),
      ),
    );
  }

  void _filterUsers(String query) {
    setState(() {
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
        onGoToProfile: () {
          if (_userInfo != null) {
            _goToProfile(_userInfo!.id);
          }
        },
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