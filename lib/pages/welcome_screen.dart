import "dart:convert";

import "package:calmwaves_app/widgets/features_card.dart";
import "package:calmwaves_app/widgets/feature.dart";
import "package:calmwaves_app/widgets/gradient_button.dart";
import "package:flutter/material.dart";

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Make it constant again.
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              const Text(
                "Welcome",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'Introduce Yourself To',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 20,),
              const Feature(title: "Managing Stress", description: "Relax & unwind with ease", emoji: "\ud83d\ude0a", setEmoji: 48,),
              const Feature(title: "Tracking Progress", description: "Monitor your mental health", emoji: "\ud83d\udcc8", setEmoji: 25,),
              const Feature(title: "Receive Support", description: "Connect with our caring", emoji: "\ud83d\udc6b", setEmoji: 48,),
              const SizedBox(
                height: 60,
              ),
              GradientButton(
                buttonMargin: 20,
                text: "Next", // It would be nice in the footer
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
