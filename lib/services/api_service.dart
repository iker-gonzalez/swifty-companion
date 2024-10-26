import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/user_model.dart';
import '../models/user_search_model.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();

  Future<UserModel?> getUserInfo(int userId) async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) {
      _logger.e('No access token found');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.intra.42.fr/v2/users/$userId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      _logger.i('User $userId info: ${response.body}'); // Log the raw response

      if (response.statusCode == 200) {
        final userInfo = jsonDecode(response.body);
        return UserModel.fromJson(userInfo);
      } else {
        _logger.e('Failed to get user info: ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Error during user info request: $e');
      return null;
    }
  }

  Future<List<UserSearchModel>> getUsersByCampus(String campusId) async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) {
      _logger.e('No access token found');
      return [];
    }

    List<UserSearchModel> allUsers = [];
    int page = 1;
    String poolYear = '2021';
    bool hasMoreResults = true;

    while (hasMoreResults) {
      try {
        final response = await http.get(
          Uri.parse('https://api.intra.42.fr/v2/campus/${campusId.toLowerCase()}/users?page=$page&per_page=100&filter[pool_year]=$poolYear'),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );
        _logger.i('Campus Users Page $page: ${response.body}'); // Log the raw response

        if (response.statusCode == 200) {
          final usersList = jsonDecode(response.body) as List<dynamic>;
          allUsers.addAll(usersList.map((user) => UserSearchModel.fromJson(user)).toList());

          // Check if there is a next page
          final linkHeader = response.headers['link'];
          if (linkHeader != null && linkHeader.contains('rel="next"')) {
            page++;
          } else {
            hasMoreResults = false;
          }
        } else {
          _logger.e('Failed to get users: ${response.body}');
          hasMoreResults = false;
        }
      } catch (e) {
        _logger.e('Error during users request: $e');
        hasMoreResults = false;
      }
    }

    return allUsers;
  }

  Future<UserModel?> getLoggedUserInfo() async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) {
      _logger.e('No access token found');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.intra.42.fr/v2/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      _logger.i('API Logged User Response: ${response.body}'); // Log the raw response

      if (response.statusCode == 200) {
        final userInfo = jsonDecode(response.body);
        return UserModel.fromJson(userInfo);
      } else {
        _logger.e('Failed to get logged user info: ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Error during logged user info request: $e');
      return null;
    }
  }
}