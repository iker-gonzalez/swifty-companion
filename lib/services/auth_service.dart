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
        final expiresIn = responseBody['expires_in'];
        await _saveAccessToken(accessToken, expiresIn);
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

  Future<void> _saveAccessToken(String token, int expiresIn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      final expirationDate = DateTime.now().add(Duration(seconds: expiresIn));
      await prefs.setString('token_expiration_date', expirationDate.toIso8601String());
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
    final expirationDateStr = prefs.getString('token_expiration_date');
    if (expirationDateStr != null) {
      final expirationDate = DateTime.parse(expirationDateStr);
      if (DateTime.now().isAfter(expirationDate)) {
        return await _refreshToken();
      }
    }
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

  Future<String?> _refreshToken() async {
    try {
      final response = await http.post(
        Uri.parse('https://api.intra.42.fr/oauth/token'),
        body: {
          'grant_type': 'refresh_token',
          'client_id': dotenv.env['CLIENT_ID']!,
          'client_secret': dotenv.env['CLIENT_SECRET']!,
          'refresh_token': await _getRefreshToken(),
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final accessToken = responseBody['access_token'];
        final expiresIn = responseBody['expires_in'];
        await _saveAccessToken(accessToken, expiresIn);
        return accessToken;
      } else {
        print('Failed to refresh access token: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during token refresh: $e');
      return null;
    }
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('token_expiration_date');
    await prefs.remove('refresh_token');
  }

}