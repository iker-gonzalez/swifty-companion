import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/user_search_model.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService _authService = AuthService();

  Future<UserModel?> getUserInfo(int userId) async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) {
      print('No access token found');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.intra.42.fr/v2/users/$userId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      print('User $userId info: ${response.body}'); // Print the raw response

      if (response.statusCode == 200) {
        final userInfo = jsonDecode(response.body);
        return UserModel.fromJson(userInfo);
      } else {
        print('Failed to get user info: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during user info request: $e');
      return null;
    }
  }

  Future<List<UserSearchModel>> getUsersByCampus(String campusId) async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) {
      print('No access token found');
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
        print('Campus Users Page $page: ${response.body}'); // Print the raw response

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
          print('Failed to get users: ${response.body}');
          hasMoreResults = false;
        }
      } catch (e) {
        print('Error during users request: $e');
        hasMoreResults = false;
      }
    }

    return allUsers;
  }

  Future<UserModel?> getLoggedUserInfo() async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) {
      print('No access token found');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.intra.42.fr/v2/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      print('API Logged User Response: ${response.body}'); // Print the raw response

      if (response.statusCode == 200) {
        final userInfo = jsonDecode(response.body);
        return UserModel.fromJson(userInfo);
      } else {
        print('Failed to get logged user info: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during logged user info request: $e');
      return null;
    }
  }
}