import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:calmwaves_app/palette.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Pallete.backgroundColor,
      title: const Text("CalmWaves"),
      centerTitle: true,
      leading: Builder(
        builder: (context) {
          return IconButton(
              onPressed: Scaffold.of(context).openDrawer,
              icon: const Icon(Icons.menu));
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            AwesomeNotifications().createNotification(
              content: NotificationContent(
                  id: 1,
                  channelKey: "basic_channel",
                  title: "CalmWaves",
                  body: "My Mental Health local notification"),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
