import "package:calmwaves_app/widgets/custom_app_bar.dart";
import "package:calmwaves_app/widgets/custom_drawer.dart";
import "package:calmwaves_app/widgets/streak_row_widget.dart";
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
      'role': data?['userinfo']?['role'] ?? 'user',
    };
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<Map<String, dynamic>> _loadStreakData(String userId) async {
  final weekly = await _getWeeklyStreaks(userId);
  final count = await _calculateStreak(userId);
  return {
    'weekly': weekly,
    'count': count,
  };
}

  Future<int> _calculateStreak(String userId) async {
    final now = DateTime.now();
    final moodSnapshot = await FirebaseFirestore.instance
        .collection('mood')
        .where('userid', isEqualTo: userId)
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

  Future<List<bool>> _getWeeklyStreaks(String userId) async {
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

  final querySnapshot = await FirebaseFirestore.instance
      .collection('mood')
      .where('userid', isEqualTo: userId)
      .where('timestamp', isGreaterThanOrEqualTo: monday)
      .where('timestamp', isLessThanOrEqualTo: sunday)
      .get();

  List<bool> weekly = List.generate(7, (_) => false);
  for (var doc in querySnapshot.docs) {
    final timestamp = (doc['timestamp'] as Timestamp).toDate();
    final dayIndex = timestamp.weekday - 1;
    weekly[dayIndex] = true;
  }

  return weekly;
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
          final role = userData['role'];
          final isGuest = role == 'guest';
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
                if (isGuest) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Vendég fiókkal vagy bejelentkezve.",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Regisztrálj, hogy elérd az összes funkciót és elmentsd az adataidat.",
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text("Regisztráció"),
                        ),
                      ],
                    ),
                  ),
                ],
                if (!isGuest) ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  FutureBuilder<Map<String, dynamic>>(
                    future:
                        _loadStreakData(FirebaseAuth.instance.currentUser!.uid),
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
                  label: const Text("Kijelentkezés"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                const SizedBox(height: 16),
                if (!isGuest)
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
