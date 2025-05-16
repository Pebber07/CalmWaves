import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  // Bejelentkezett felhasználó neve
  Future<String> _getUsername() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return userDoc.data()?['userinfo']['username'] ?? 'Felhasználó';
    }

    return 'Felhasználó';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          FutureBuilder<String>(
            future: _getUsername(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text(
                    'Betöltés...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text(
                    'Hiba történt!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                );
              } else {
                return DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text(
                    snapshot.data ?? 'Felhasználó',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                );
              }
            },
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
            title: const Text('Hangulat'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/mood');
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
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Értesítések'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          ListTile(
            leading: const Icon(Icons.healing),
            title: const Text('Napló'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/journal');
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Beszélgetés'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/chatbot');
            },
          ),
          ListTile(
            leading: const Icon(Icons.forum),
            title: const Text('Fórum'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/forum');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Felhasználók kezelése'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/manage_users');
            },
          ),
        ],
      ),
    );
  }
}
