import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> openAuthorizationUrl() async {
    final url = getAuthorizationUrl();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
        return responseBody['access_token'];
      } else {
        print('Failed to get access token: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during token exchange: $e');
      return null;
    }
  }
}