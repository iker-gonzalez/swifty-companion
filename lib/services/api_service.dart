// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class ApiService {
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<UserModel?> getUserInfo(int userId) async {
    final accessToken = await getAccessToken();
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
      print('API User Response: ${response.body}'); // Print the raw response

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

  Future<List<UserModel>> getUsersByCampus(String campusId) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      print('No access token found');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.intra.42.fr/v2/campus/${campusId.toLowerCase()}/users'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      print('API Users Response: ${response.body}'); // Print the raw response

      if (response.statusCode == 200) {
        final usersList = jsonDecode(response.body) as List<dynamic>;
        return usersList.map((user) => UserModel.fromJson(user)).toList();
      } else {
        print('Failed to get users: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error during users request: $e');
      return [];
    }
  }

  Future<UserModel?> getLoggedUserInfo() async {
    final accessToken = await getAccessToken();
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