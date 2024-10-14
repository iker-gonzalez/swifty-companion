import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
final String title;
final bool showBackButton;

const Header({super.key, required this.title, this.showBackButton = false});

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
);
}

@override
Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}