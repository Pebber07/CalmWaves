import "package:flutter/material.dart";
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Horizontally scrollable widget, that shows the streak days.
class StreakRowWidget extends StatelessWidget {
  final List<bool> weeklyStreaks;
  final int currentStreakCount;

  const StreakRowWidget({
    super.key,
    required this.weeklyStreaks,
    required this.currentStreakCount,
  });

  @override
  Widget build(BuildContext context) {
    var dayLabels = [
      AppLocalizations.of(context)!.monday,
      AppLocalizations.of(context)!.tuesday,
      AppLocalizations.of(context)!.wednesday,
      AppLocalizations.of(context)!.thursday,
      AppLocalizations.of(context)!.friday,
      AppLocalizations.of(context)!.saturday,
      AppLocalizations.of(context)!.sunday
    ]; // [i:0..6]
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.weekyActivity,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(7, (index) {
              final isActive = weeklyStreaks[index];
              final imagePath = isActive
                  ? 'assets/images/streak_fire.png'
                  : 'assets/images/non_streak_fire.png';

              final date = monday.add(Duration(days: index));
              final formattedDate = DateFormat('yyyy.MM.dd').format(date);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    Tooltip(
                      message: formattedDate,
                      child: Image.asset(
                        imagePath,
                        width: 40,
                        height: 40,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayLabels[index],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              "$currentStreakCount nap",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            Image.asset(
              'assets/images/streak_fire.png',
              width: 24,
              height: 24,
            ),
          ],
        ),
      ],
    );
  }
}
