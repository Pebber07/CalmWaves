import "package:flutter/material.dart";

class FeelingCard extends StatelessWidget {
  final String caption;
  final Color cardColor;
  final String emoji;
  final double cardWidth;
  const FeelingCard(
      {super.key,
      required this.caption,
      required this.cardColor,
      required this.emoji,
      required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(
          8), // make it close to each other (journal_screen)
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
    );
  }
}
