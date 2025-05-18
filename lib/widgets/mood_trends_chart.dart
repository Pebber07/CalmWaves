import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MoodTrendsChart extends StatelessWidget {
  const MoodTrendsChart({super.key});

  Future<Map<String, List<FlSpot>>> _getMoodDataGroupedByMonth() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return {};

    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    final yearMonthKey =
        "$currentYear-${currentMonth.toString().padLeft(2, '0')}";

    final querySnapshot = await FirebaseFirestore.instance
        .collection('mood')
        .where('userid', isEqualTo: currentUser.uid)
        .orderBy('timestamp')
        .get();

    final Map<String, Map<int, List<double>>> grouped = {};

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final moodNumber = (data['moodNumber'] as num).toDouble();

      // csak az aktuális hónap
      if (timestamp.year != currentYear || timestamp.month != currentMonth) {
        continue;
      }

      final day = timestamp.day;
      grouped.putIfAbsent(yearMonthKey, () => {});
      grouped[yearMonthKey]!.putIfAbsent(day, () => []);
      grouped[yearMonthKey]![day]!.add(moodNumber);
    }

    final Map<String, List<FlSpot>> result = {};

    grouped.forEach((month, daysMap) {
      final spots = daysMap.entries.map((e) {
        final day = e.key;
        final moodAvg = e.value.reduce((a, b) => a + b) / e.value.length;
        return FlSpot(day.toDouble(), moodAvg);
      }).toList();

      result[month] = spots;
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<FlSpot>>>(
      future: _getMoodDataGroupedByMonth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(AppLocalizations.of(context)!.noMoodData));
        }

        final dataByMonth = snapshot.data!;
        final monthKey = dataByMonth.keys.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: dataByMonth[monthKey]!,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.cyan,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      axisNameWidget: Text(AppLocalizations.of(context)!.days),
                      axisNameSize: 28,
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 2,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 1:
                              return const Text("\ud83d\ude20");
                            case 3:
                              return const Text("\ud83d\ude10");
                            case 6:
                              return const Text("\ud83d\ude0d");
                            default:
                              return const SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) =>
                            const SizedBox.shrink(),
                        reservedSize: 32,
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
