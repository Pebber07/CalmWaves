import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:calmwaves_app/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue, //Pallete.backgroundColor,
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
