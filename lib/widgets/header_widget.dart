// lib/widgets/header_widget.dart
import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool isLoggedIn;
  final String profilePictureUrl;
  final VoidCallback onLogout;
  final VoidCallback onGoToProfile;

  const Header({
    super.key,
    required this.title,
    this.showBackButton = false,
    required this.isLoggedIn,
    required this.profilePictureUrl,
    required this.onLogout,
    required this.onGoToProfile,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white), // Set the title color to white
      ),
      backgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.white), // Set the icon color to white
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      )
          : null,
      actions: [
        if (isLoggedIn)
          PopupMenuButton<int>(
            icon: CircleAvatar(
              backgroundImage: NetworkImage(profilePictureUrl),
            ),
            onSelected: (item) {
              if (item == 0) {
                onGoToProfile();
              } else if (item == 1) {
                onLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 0,
                child: Text('Go to My Profile'),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Text('Logout'),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}