import "package:calmwaves_app/widgets/custom_app_bar.dart";
import "package:calmwaves_app/widgets/custom_drawer.dart";
import "package:calmwaves_app/widgets/feeling_card.dart";
import "package:calmwaves_app/widgets/gradient_button.dart";
import "package:calmwaves_app/widgets/mood_trends_chart.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const Text(
                "How are you today?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const Row(
                children: [
                  FeelingCard(
                    caption: "Mérges",
                    cardColor: Colors.red,
                    emoji: "\ud83d\ude20",
                    cardWidth: 100,
                    moodNumber: 1,
                  ),
                  FeelingCard(
                    caption: "Szomorú",
                    cardColor: Colors.orange,
                    emoji: "\ud83d\ude41",
                    cardWidth: 100,
                    moodNumber: 2,
                  ),
                  FeelingCard(
                    caption: "Elmegy",
                    cardColor: Colors.yellow,
                    emoji: "\ud83d\ude10",
                    cardWidth: 100,
                    moodNumber: 3,
                  ),
                ],
              ), // I could create an Enum for this.
              const Row(
                children: [
                  FeelingCard(
                    caption: "Boldog",
                    cardColor: Colors.lightBlue,
                    emoji: "\ud83d\ude0a",
                    cardWidth: 100,
                    moodNumber: 4,
                  ),
                  FeelingCard(
                    caption: "Izgatott",
                    cardColor: Colors.cyan,
                    emoji: "\ud83d\ude04",
                    cardWidth: 100,
                    moodNumber: 5,
                  ),
                  FeelingCard(
                    caption: "Ultra vidám",
                    cardColor: Colors.purple,
                    emoji: "\ud83d\ude0d",
                    cardWidth: 100,
                    moodNumber: 6,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Mood History",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(
                height: 10,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('mood')
                    .where('userid', isEqualTo: currentUser?.uid)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("No mood history found.");
                  }

                  final moodDocs = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: moodDocs.length,
                    itemBuilder: (context, index) {
                      final moodData =
                          moodDocs[index].data() as Map<String, dynamic>;
                      final emoji = moodData['emoji'] as String;
                      final caption = moodData['caption'] as String;
                      final timestamp =
                          (moodData['timestamp'] as Timestamp).toDate();

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        child: ListTile(
                          leading: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(caption),
                          subtitle: Text(
                            "${timestamp.year}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.day.toString().padLeft(2, '0')}",
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Mood Trends",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: const MoodTrendsChart(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
