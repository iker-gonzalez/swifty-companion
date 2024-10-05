// lib/auth_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();

  String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
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

  Future<String?> login() async {
    try {
      final AuthorizationTokenResponse? result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          dotenv.env['CLIENT_ID']!,
          dotenv.env['REDIRECT_URI']!,
          issuer: dotenv.env['ISSUER']!,
          scopes: ['public'],
        ),
      );

      return result?.accessToken;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<String?> exchangeCodeForToken(String code) async {
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
      return responseBody['access_token'];
    } else {
      print('Failed to get access token: ${response.body}');
      return null;
    }
  }
}