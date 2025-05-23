import 'package:cloud_firestore/cloud_firestore.dart';

/// Calculate the streaks, the number of days, where the users filled their mood consecutively. 
class UserStreakService {
  static Future<int> calculateCurrentStreak(String userId) async {
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

  static Future<List<bool>> getWeeklyStreaks(String userId) async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59));

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
}
