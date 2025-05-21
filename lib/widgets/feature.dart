import "package:flutter/material.dart";

class Feature extends StatelessWidget {
  final String title;
  final String description;
  final String emoji;
  final double setEmoji;
  const Feature(
      {super.key,
      required this.title,
      required this.description,
      required this.emoji,
      required this.setEmoji});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
              ),
              Text(
                description,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: setEmoji),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
