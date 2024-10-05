// lib/auth_service.dart
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();

  Future<String?> login() async {
    try {
      final AuthorizationTokenResponse? result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          dotenv.env['CLIENT_ID']!,
          dotenv.env['REDIRECT_URI']!,
          issuer: dotenv.env['ISSUER']!,
          scopes: ['openid', 'profile', 'email'],
        ),
      );

      return result?.accessToken;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}