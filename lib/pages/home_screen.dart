import 'package:calmwaves_app/palette.dart';
import 'package:calmwaves_app/widgets/activity_type.dart';
import 'package:calmwaves_app/widgets/custom_app_bar.dart';
import 'package:calmwaves_app/widgets/event_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:calmwaves_app/widgets/gradient_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          const Center(
            child: Text(
              "Today's Mood Events",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return EventCard(
                    date: 18 + index,
                    title: "Mindful Pilates",
                    description: "Self-care",
                    activityType: ActivityType.indoors,
                    profileImage: "assets/images/own_profile_pic.jpg");
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Pallete.backgroundColor,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: "Calendar"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Journal"),
        ],
      ),
    );
  }
}
