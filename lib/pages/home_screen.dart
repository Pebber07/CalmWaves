import 'package:calmwaves_app/pages/create_event_screen.dart';
import 'package:calmwaves_app/palette.dart';
import 'package:calmwaves_app/widgets/activity_type.dart';
import 'package:calmwaves_app/widgets/custom_app_bar.dart';
import 'package:calmwaves_app/widgets/custom_drawer.dart';
import 'package:calmwaves_app/widgets/event_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:calmwaves_app/widgets/gradient_button.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime currentDate = DateTime.now();
  DateTime selectedDate = DateTime.now();

  List<QueryDocumentSnapshot> events = [];

  Future<void> _getEventsForDay(DateTime date) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final formattedDate = DateFormat("yyyy-MM-dd").format(date);

    final snapshot = await FirebaseFirestore.instance
        .collection("events")
        .where("author", isEqualTo: userId)
        .where("day", isEqualTo: formattedDate)
        .get();

    setState(
      () {
        events = snapshot.docs;
      },
    );
  }

  List<DateTime> _getWeeksDays(DateTime date) {
    final firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(
      7,
      (index) {
        return firstDayOfWeek.add(Duration(days: index));
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getEventsForDay(currentDate);
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeeksDays(currentDate);

    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          // Görgethető hét napjai
          SizedBox(
            height: 120,
            child: ListView.builder(
              itemCount: weekDays.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final day = weekDays[index];
                final formattedDay = DateFormat('EEE').format(day);
                final isSelected = selectedDate.isSameDate(day);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = day;
                    });
                    _getEventsForDay(day);
                  },
                  child: Column(
                    children: [
                      Text(formattedDay),
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(16),
                          color: isSelected ? Colors.blue : Colors.grey,
                        ),
                        child: Align(
                          child: Text(
                            DateFormat('d').format(day),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index].data() as Map<String, dynamic>;
                return EventCard(
                  title: event['title'],
                  description: event['description'],
                  author: event['author'],
                  createTime: event['createTime'],
                  time: event['time'],
                  eventDate: DateTime.parse(event['day']),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEventScreen(),
            ),
          );
        },
      ),
    );
  }
}

extension DateTimeComparison on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
