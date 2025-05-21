import "package:calmwaves_app/pages/register_screen.dart";
import "package:calmwaves_app/widgets/feature.dart";
import "package:calmwaves_app/widgets/gradient_button.dart";
import "package:flutter/material.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WelcomeScreen extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const WelcomeScreen(),
      );
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
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
              Text(
                AppLocalizations.of(context)!.welcome,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                AppLocalizations.of(context)!.introduce,
                style: const TextStyle(
                  fontSize: 25,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Feature(
                title: AppLocalizations.of(context)!.managingStress,
                description: AppLocalizations.of(context)!.relax,
                emoji: "\ud83d\ude0a",
                setEmoji: 48,
              ),
              Feature(
                title: AppLocalizations.of(context)!.trackingProgress,
                description: AppLocalizations.of(context)!.monitorMentalHealth,
                emoji: "\ud83d\udcc8",
                setEmoji: 25,
              ),
              Feature(
                title: AppLocalizations.of(context)!.receiveSupport,
                description: AppLocalizations.of(context)!.connectOurcaring,
                emoji: "\ud83d\udc6b",
                setEmoji: 35,
              ),
              const SizedBox(
                height: 40,
              ),
              GradientButton(
                buttonMargin: 20,
                text: AppLocalizations.of(context)!
                    .next, // It would be nice in the footer
                onPressed: () {
                  Navigator.push(context, RegisterScreen.route());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
