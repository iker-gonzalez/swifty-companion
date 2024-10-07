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
}