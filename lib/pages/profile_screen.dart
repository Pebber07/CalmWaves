import "package:calmwaves_app/widgets/custom_app_bar.dart";
import "package:calmwaves_app/widgets/custom_drawer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

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
    };
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<int> _calculateStreak(String userId) async {
    final now = DateTime.now();
    final moodSnapshot = await FirebaseFirestore.instance
        .collection('mood')
        .where('userId', isEqualTo: userId)
        .get();

    final loggedDates = <DateTime>{};

    for (var doc in moodSnapshot.docs) {
      final timestamp = doc['timestamp'] as Timestamp;
      final date = timestamp.toDate();
      loggedDates.add(DateTime(date.year, date.month, date.day));
    }

    int streak = 0;
    DateTime current = DateTime(now.year, now.month, now.day);

    while (loggedDates.contains(current)) {
      streak += 1;
      current = current.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Fiók zárolása"),
        content: const Text("Biztosan törölni szeretnéd a fiókodat?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Mégse")),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Törlés")),
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
          title: const Text("Újrahitelesítés"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add meg a jelszavad a törlés megerősítéséhez:"),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Jelszó"),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Mégse")),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Folytatás")),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Hiba történt a fiók zárolása közben."),
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
          final profileImage = userData['profileImage'];
          final formattedDate = createdAt != null
              ? DateFormat('yyyy.MM.dd').format(createdAt.toDate())
              : 'Ismeretlen';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: profileImage.isNotEmpty
                        ? NetworkImage(profileImage)
                        : null,
                    child: profileImage.isEmpty
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  username,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("Regisztráció: $formattedDate"),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                FutureBuilder<int>(
                  future:
                      _calculateStreak(FirebaseAuth.instance.currentUser!.uid),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final streak = snapshot.data!;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Aktivitás", style: TextStyle(fontSize: 18)),
                        Row(
                          children: [
                            Text(
                              "$streak nap",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            Image.asset(
                              "assets/images/streak_fire.png",
                              width: 24,
                              height: 24,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => _signOut(context),
                  icon: const Icon(Icons.logout),
                  label: const Text("Kijelentkezés"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _deleteAccount(context),
                  icon: const Icon(Icons.lock_outline),
                  label: const Text("Profil zárolása"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
