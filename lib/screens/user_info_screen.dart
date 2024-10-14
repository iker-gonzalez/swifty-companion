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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Align to the top
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16.0), // Add top margin
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(userInfo.profilePicture.isNotEmpty
                      ? userInfo.profilePicture
                      : 'https://via.placeholder.com/150'),
                ),
              ),
              const SizedBox(height: 16),
              Text('ID: ${userInfo.id}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('First Name: ${userInfo.firstName}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Last Name: ${userInfo.lastName}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Login: ${userInfo.login}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Email: ${userInfo.email}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Phone: ${userInfo.phone ?? "N/A"}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Level: ${userInfo.level}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Location: ${userInfo.location ?? "N/A"}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Wallet: ${userInfo.wallet}', style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}