import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class FeelingCard extends StatelessWidget {
  final String caption;
  final Color cardColor;
  final String emoji;
  final double cardWidth;
  final int moodNumber;
  const FeelingCard(
      {super.key,
      required this.caption,
      required this.cardColor,
      required this.emoji,
      required this.cardWidth,
      required this.moodNumber});

  Future<void> _saveMood(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please log in to save your mood."),
          ),
        );
        return;
      }
      final moodData = {
        "userid": user.uid,
        "timestamp": DateTime.now(),
        "emoji": emoji,
        "caption": caption,
        "moodNumber": moodNumber,
      };

      await FirebaseFirestore.instance.collection("mood").add(moodData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mood saved successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hiba hangulat mentése közben: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _saveMood(context),
      child: Container(
        margin: const EdgeInsets.all(
            8), 
        padding: const EdgeInsets.all(20),
        width: cardWidth,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$emoji $caption"),
          ],
        ),
      ),
    );
  }
}
