import "package:calmwaves_app/palette.dart";
import "package:calmwaves_app/widgets/activity_type.dart";
import "package:flutter/material.dart";

class EventCard extends StatelessWidget {
  final int date;
  final String title;
  final String description;
  final ActivityType activityType; // corrected
  final String profileImage;
  const EventCard({
    super.key, // bit diffenrent
    required this.date,
    required this.title,
    required this.description,
    required this.activityType,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Pallete.gradient1,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.black,
                  child: Text(date.toString()),
                ),
                const SizedBox(
                  height: 4,
                ),
                const Text("Imp") // Dynamic Month Abbrevation
              ],
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(description),
                  const SizedBox(
                    height: 8,
                  ),
                  Chip(
                    label: Text(activityType.name),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              backgroundImage: AssetImage(profileImage),
              radius: 20,
            ),
          ],
        ),
      ),
    );
  }
}
