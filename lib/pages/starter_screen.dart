import 'package:calmwaves_app/pages/login_screen.dart';
import 'package:calmwaves_app/pages/register_screen.dart';
import 'package:calmwaves_app/pages/welcome_screen.dart';
import 'package:calmwaves_app/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
              Text(
                  textAlign: TextAlign.center,
                  AppLocalizations.of(context)!.securelyManage),
              const SizedBox(
                height: 15,
              ),
              Image.asset(
                // 'assets/images/joga_picture.png',
                'assets/images/good_wave.png',
                width: 300,
                height: 300,
              ),
              const SizedBox(
                height: 45,
              ),
              GradientButton(
                buttonMargin: 20,
                text: AppLocalizations.of(context)!.getStarted,
                onPressed: () {
                  Navigator.push(context, WelcomeScreen.route());
                },
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, RegisterScreen.route());
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 45),
                      child: RichText(
                        text: TextSpan(
                          text: AppLocalizations.of(context)!.register,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
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
                          text: AppLocalizations.of(context)!.alreadyAMember,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
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
