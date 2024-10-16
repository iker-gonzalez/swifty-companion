// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';

class ApiService {
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<UserModel?> getUserInfo() async {
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
      print('API Response: ${response.body}'); // Print the raw response

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to get user info: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during user info request: $e');
      return null;
    }
  }

  Future<List<ProjectModel>?> getUserProjects() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      print('No access token found');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.intra.42.fr/v2/users/88036/projects_users?&page[size]=100'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      print('API Response: ${response.body}'); // Print the raw response

      if (response.statusCode == 200) {
        List<dynamic> projectsJson = jsonDecode(response.body);
        return projectsJson.map((json) => ProjectModel.fromJson(json)).toList();
      } else {
        print('Failed to get user projects: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during user projects request: $e');
      return null;
    }
  }
}