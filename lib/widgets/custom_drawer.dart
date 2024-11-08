import "package:flutter/material.dart";

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Navigációs Menü',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Kezdőlap'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Beállítások'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Cikkek'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/articles');
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Események'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/events');
            },
          ),
          ListTile(
            leading: const Icon(Icons.health_and_safety),
            title: const Text('Napló'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/journal');
            },
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Bejelentkezés'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
          ),
          ListTile(
            leading: const Icon(Icons.app_registration_outlined),
            title: const Text('Regisztráció'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/register');
            },
          ),
          ListTile(
            leading: const Icon(Icons.start),
            title: const Text('Nyitó oldal'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/starter');
            },
          ),
          ListTile(
            leading: const Icon(Icons.first_page),
            title: const Text('Köszöntő oldal'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/welcome');
            },
          ),
        ],
      ),
    );
  }
}
