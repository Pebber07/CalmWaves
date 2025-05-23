import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue, 
      title: const Text(
        "CalmWaves",
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      leading: Builder(
        builder: (context) {
          return IconButton(
            color: Colors.white,
              onPressed: Scaffold.of(context).openDrawer,
              icon: const Icon(Icons.menu));
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
