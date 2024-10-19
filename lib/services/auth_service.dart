import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }

  String getAuthorizationUrl() {
    final clientId = dotenv.env['CLIENT_ID']!;
    final redirectUri = dotenv.env['REDIRECT_URI']!;
    final state = generateRandomString(16);
    const scope = 'public';
    const responseType = 'code';
    const baseUrl = 'https://api.intra.42.fr/oauth/authorize';

    return '$baseUrl?client_id=$clientId&redirect_uri=$redirectUri&response_type=$responseType&scope=$scope&state=$state';
  }

  Future<String?> exchangeCodeForToken(String code) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.intra.42.fr/oauth/token'),
        body: {
          'grant_type': 'authorization_code',
          'client_id': dotenv.env['CLIENT_ID']!,
          'client_secret': dotenv.env['CLIENT_SECRET']!,
          'code': code,
          'redirect_uri': dotenv.env['REDIRECT_URI']!,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final accessToken = responseBody['access_token'];
        await _saveAccessToken(accessToken);
        return accessToken;
      } else {
        print('Failed to get access token: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during token exchange: $e');
      return null;
    }
  }

  Future<void> _saveAccessToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
    } catch (e) {
      print('Error saving access token: $e');
    }
  }

  Future<bool> checkAccessToken() async {
    final accessToken = await getAccessToken();
    return accessToken != null;
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> printAccessToken() async {
    final accessToken = await getAccessToken();
    if (accessToken != null) {
      print('Access Token: $accessToken');
    } else {
      print('No access token found');
    }
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
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
        return jsonDecode(response.body);
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