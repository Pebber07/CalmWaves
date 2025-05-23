import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calmwaves_app/services/user_streak_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      'role': data?['userinfo']?['role'] ?? 'guest',
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
            child: FutureBuilder<Map<String, dynamic>>(
              future: _getUserInfo(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final role = snapshot.data!['role'] ?? 'guest';
                final List<Widget> drawerItems = [];

                if (role == 'guest') {
                  drawerItems.addAll([
                    _drawerItem(context, Icons.home,
                        AppLocalizations.of(context)!.home, '/home'),
                    _drawerItem(context, Icons.book,
                        AppLocalizations.of(context)!.journal, '/journal'),
                    _drawerItem(context, Icons.person,
                        AppLocalizations.of(context)!.profile, '/profile'),
                    _drawerItem(context, Icons.settings,
                        AppLocalizations.of(context)!.settings, '/settings'),
                  ]);
                } else if (role == 'user') {
                  drawerItems.addAll([
                    _drawerItem(context, Icons.home,
                        AppLocalizations.of(context)!.home, '/home'),
                    _drawerItem(context, Icons.book,
                        AppLocalizations.of(context)!.journal, '/journal'),
                    _drawerItem(context, Icons.mood,
                        AppLocalizations.of(context)!.mood, '/mood'),
                    _drawerItem(context, Icons.forum,
                        AppLocalizations.of(context)!.forum, '/forum'),
                    _drawerItem(context, Icons.assistant,
                        AppLocalizations.of(context)!.assistant, '/chatbot'),
                    _drawerItem(context, Icons.article,
                        AppLocalizations.of(context)!.articles, '/articles'),
                    _drawerItem(context, Icons.person,
                        AppLocalizations.of(context)!.profile, '/profile'),
                    _drawerItem(context, Icons.settings,
                        AppLocalizations.of(context)!.settings, '/settings'),
                  ]);
                } else if (role == 'admin') {
                  drawerItems.addAll([
                    _drawerItem(context, Icons.home,
                        AppLocalizations.of(context)!.home, '/home'),
                    _drawerItem(context, Icons.book,
                        AppLocalizations.of(context)!.journal, '/journal'),
                    _drawerItem(context, Icons.mood,
                        AppLocalizations.of(context)!.mood, '/mood'),
                    _drawerItem(context, Icons.forum,
                        AppLocalizations.of(context)!.forum, '/forum'),
                    _drawerItem(context, Icons.assistant,
                        AppLocalizations.of(context)!.assistant, '/chatbot'),
                    _drawerItem(context, Icons.article,
                        AppLocalizations.of(context)!.articles, '/articles'),
                    _drawerItem(
                        context,
                        Icons.notifications,
                        AppLocalizations.of(context)!.notifications,
                        '/notifications'),
                    _drawerItem(
                        context,
                        Icons.person,
                        AppLocalizations.of(context)!.manageUsers,
                        '/manage_users'),
                    _drawerItem(context, Icons.person,
                        AppLocalizations.of(context)!.profile, '/profile'),
                    _drawerItem(context, Icons.settings,
                        AppLocalizations.of(context)!.settings, '/settings'),
                  ]);
                }

                return ListView(
                  padding: EdgeInsets.zero,
                  children: drawerItems,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
