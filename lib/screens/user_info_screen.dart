// lib/screens/user_info_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../widgets/header_widget.dart';

class UserInfoScreen extends StatelessWidget {
  final UserModel userInfo;

  const UserInfoScreen({super.key, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: 'User Info', showBackButton: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('ID: ${userInfo.id}'),
            Text('Login: ${userInfo.login}'),
            Text('Email: ${userInfo.email}'),
          ],
        ),
      ),
    );
  }
}