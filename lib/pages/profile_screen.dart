import "package:calmwaves_app/widgets/custom_app_bar.dart";
import "package:calmwaves_app/widgets/custom_drawer.dart";
import "package:calmwaves_app/widgets/streak_row_widget.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import 'package:calmwaves_app/widgets/profile_picture_picker.dart';
import 'package:calmwaves_app/services/user_streak_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Profile Screen where the users can see the streak, log out, and delete their profile.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> _fetchUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!doc.exists) return null;

    final data = doc.data();
    return {
      'username': data?['userinfo']?['username'] ?? '',
      'createdAt': data?['userinfo']?['createdAt'],
      'profileImage': data?['userinfo']?['profileImage'] ?? '',
      'role': data?['userinfo']?['role'] ?? 'user',
    };
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteProfile),
        content: Text(AppLocalizations.of(context)!.sureDeleteProfile),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLocalizations.of(context)!.delete)),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final email = user.email!;
      final passwordController = TextEditingController();

      final success = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.reauthenticate),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.enterYourPassword),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.password),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(AppLocalizations.of(context)!.cancel)),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(AppLocalizations.of(context)!.continueC)),
          ],
        ),
      );

      if (success != true) return;

      final credential = EmailAuthProvider.credential(
        email: email,
        password: passwordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();
      await user.delete();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(AppLocalizations.of(context)!.errorOccuredDuringProfileDelete),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!;
          final username = userData['username'];
          final createdAt = userData['createdAt'] as Timestamp?;
          final role = userData['role'];
          final isGuest = role == 'guest';
          final formattedDate = createdAt != null
              ? DateFormat('yyyy.MM.dd').format(createdAt.toDate())
              : 'Ismeretlen';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                const ProfilePicturePicker(),
                const SizedBox(height: 16),
                Text(
                  username,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                    "${AppLocalizations.of(context)!.register}: $formattedDate"),
                const SizedBox(height: 16),
                if (isGuest) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.guestLoggedIn,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!
                              .registerToAccessEveryFunc,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text(AppLocalizations.of(context)!.register),
                        ),
                      ],
                    ),
                  ),
                ],
                if (!isGuest) ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  FutureBuilder<Map<String, dynamic>>(
                    future: Future.wait([
                      UserStreakService.getWeeklyStreaks(
                          FirebaseAuth.instance.currentUser!.uid),
                      UserStreakService.calculateCurrentStreak(
                          FirebaseAuth.instance.currentUser!.uid),
                    ]).then((results) => {
                          'weekly': results[0],
                          'count': results[1],
                        }),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final weeklyStreaks =
                          snapshot.data!['weekly'] as List<bool>;
                      final currentStreakCount = snapshot.data!['count'] as int;

                      return StreakRowWidget(
                        weeklyStreaks: weeklyStreaks,
                        currentStreakCount: currentStreakCount,
                      );
                    },
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => _signOut(context),
                  icon: const Icon(Icons.logout),
                  label: Text(AppLocalizations.of(context)!.logOut),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                const SizedBox(height: 16),
                if (!isGuest)
                  OutlinedButton.icon(
                    onPressed: () => _deleteAccount(context),
                    icon: const Icon(
                      Icons.lock_outline,
                      color: Colors.black,
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.deleteProfile,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
