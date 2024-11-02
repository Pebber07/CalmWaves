import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:calmwaves_app/widgets/gradient_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Image.asset('assets/images/signin_balls.png'),
              const Text(
                'HomePage',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              GradientButton(
                text: "Log out",
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
