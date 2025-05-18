import 'package:calmwaves_app/palette.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChooseDayWidget extends StatefulWidget {
  final Function(DateTime) onDateChanged;
  const ChooseDayWidget({
    super.key,
    required this.onDateChanged,
  });

  @override
  State<ChooseDayWidget> createState() => _ChooseDayWidgetState();
}

class _ChooseDayWidgetState extends State<ChooseDayWidget> {
  DateTime selectedMonth = DateTime.now();
  DateTime? selectedDay;

  List<int> getDaysInMonth(DateTime month) {
    // final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    List<int> days = [];
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      days.add(i);
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    List<int> days = getDaysInMonth(selectedMonth);

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Card(
        color: Pallete.gradient2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        selectedMonth = DateTime(
                            selectedMonth.year, selectedMonth.month - 1);
                      });
                    },
                  ),
                  Text(
                    '${selectedMonth.year} - ${selectedMonth.month}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      setState(() {
                        selectedMonth = DateTime(
                            selectedMonth.year, selectedMonth.month + 1);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMMM yyyy').format(selectedMonth),
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  int day = days[index];
                  DateTime currentDay =
                      DateTime(selectedMonth.year, selectedMonth.month, day);

                  bool isToday = currentDay.day == DateTime.now().day &&
                      currentDay.month == DateTime.now().month &&
                      currentDay.year == DateTime.now().year;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDay = currentDay;
                      });
                      widget.onDateChanged(currentDay);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              isToday ? Colors.yellow : Pallete.gradient1,
                          child: Text(
                            "$day",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        if (selectedDay?.day == day)
                          Positioned(
                            bottom: 0,
                            child: Container(
                              color: Colors.lightBlue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              child: Text(
                                AppLocalizations.of(context)!.marked,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
