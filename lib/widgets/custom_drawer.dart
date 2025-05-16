import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calmwaves_app/services/user_streak_service.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  Future<Map<String, dynamic>> _getUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {
        'username': 'Vendég',
        'profileImage': 'gs://profile_pictures/template_profile_picture',
        'userId': '',
      };
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = userDoc.data();
    return {
      'username': data?['userinfo']?['username'] ?? 'Ismeretlen',
      'profileImage': data?['userinfo']?['profileImage'] ??
          'gs://profile_pictures/template_profile_picture',
      'userId': user.uid,
    };
  }

  Widget _drawerItem(
      BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _getUserInfo(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                );
              }

              final username = snapshot.data!['username'];
              final profileImage = snapshot.data!['profileImage'];
              final userId = snapshot.data!['userId'];

              return FutureBuilder<int>(
                future: UserStreakService.calculateCurrentStreak(userId),
                builder: (context, streakSnapshot) {
                  final streak = streakSnapshot.data ?? 0;

                  return DrawerHeader(
                    decoration: const BoxDecoration(color: Colors.blue),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: profileImage.startsWith('http')
                              ? NetworkImage(profileImage)
                              : null,
                          backgroundColor: Colors.white24,
                          child: profileImage.startsWith('gs://')
                              ? const Icon(Icons.person,
                                  size: 30, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                username,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$streak 🔥',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(context, Icons.home, 'Kezdőlap', '/home'),
                _drawerItem(
                    context, Icons.settings, 'Beállítások', '/settings'),
                _drawerItem(context, Icons.article, 'Cikkek', '/articles'),
                _drawerItem(context, Icons.event, 'Események', '/events'),
                _drawerItem(
                    context, Icons.health_and_safety, 'Hangulat', '/mood'),
                _drawerItem(context, Icons.login, 'Bejelentkezés', '/login'),
                _drawerItem(context, Icons.app_registration_outlined,
                    'Regisztráció', '/register'),
                _drawerItem(context, Icons.start, 'Nyitó oldal', '/starter'),
                _drawerItem(
                    context, Icons.first_page, 'Köszöntő oldal', '/welcome'),
                _drawerItem(context, Icons.notifications, 'Értesítések',
                    '/notifications'),
                _drawerItem(context, Icons.healing, 'Napló', '/journal'),
                _drawerItem(context, Icons.chat, 'Beszélgetés', '/chatbot'),
                _drawerItem(context, Icons.forum, 'Fórum', '/forum'),
                _drawerItem(context, Icons.person, 'Profil', '/profile'),
                _drawerItem(context, Icons.person, 'Felhasználók kezelése',
                    '/manage_users'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
