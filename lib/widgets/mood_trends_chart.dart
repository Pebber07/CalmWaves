import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";

class MoodTrendsChart extends StatelessWidget {
  const MoodTrendsChart({super.key});

  Future<List<FlSpot>> _getMoodData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return [];
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('mood')
        .where('userid', isEqualTo: currentUser.uid)
        .orderBy('timestamp', descending: false)
        .get();

    final moodData = querySnapshot.docs.map((doc) {
      final data = doc.data();
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final moodNumber = data['moodNumber'] as int;

      return FlSpot(timestamp.day.toDouble(), moodNumber.toDouble());
    }).toList();

    return moodData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FlSpot>>(
      future: _getMoodData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No mood data to display."));
        }

        final moodSpots = snapshot.data!;

        return LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: moodSpots,
                isCurved: true,
                barWidth: 4,
                belowBarData: BarAreaData(show: false),
              ),
            ],
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toInt().toString(),
                        style: const TextStyle(fontSize: 12));
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toInt().toString(),
                        style: const TextStyle(fontSize: 12));
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
          ),
        );
      },
    );
  }
}
