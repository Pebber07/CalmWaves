import 'package:calmwaves_app/pages/login_screen.dart';
import 'package:calmwaves_app/widgets/gradient_button.dart';
import 'package:flutter/material.dart';

class StarterScreen extends StatelessWidget {
  const StarterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              const Text(
                "CalmWaves",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                  "Securely manage your mental health journey\n and get personalized advice in one place. "),
              const SizedBox(
                height: 15,
              ),
              Image.asset(
                'assets/images/joga_picture.png',
                width: 300,
                height: 300,
              ),
              const SizedBox(
                height: 40,
              ),
              GradientButton(
                buttonMargin: 20,
                text: "Get Started",
                onPressed: () {},
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, LoginScreen.route());
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 45),
                      child: RichText(
                        text: TextSpan(
                          text: 'Already a member?',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, LoginScreen.route());
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 65),
                      child: RichText(
                        text: TextSpan(
                          text: 'Register',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
