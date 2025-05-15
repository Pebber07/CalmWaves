import "package:calmwaves_app/pages/register_screen.dart";
import "package:calmwaves_app/services/google_auth.dart";
import "package:calmwaves_app/widgets/check_internet.dart";
import "package:calmwaves_app/widgets/gradient_button.dart";
import "package:calmwaves_app/widgets/language_selector_widget.dart";
import "package:calmwaves_app/widgets/login_field.dart";
import "package:calmwaves_app/widgets/social_button.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:google_sign_in/google_sign_in.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  final googleAuthService = GoogleAuthService();

  Future<void> loginUserWithEmailAndPassword() async {
    if (!await hasInternetConnection()) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Nincs internetkapcsolat"),
          content: Text("Kérlek, csatlakozz egy hálózathoz."),
        ),
      );
      return;
    }

    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Hiba'),
          content: Text('Kérem, az összes mezőt töltse ki!'),
        ),
      );
      return;
    }

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!userCredential.user!.emailVerified) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text('Email not verified'),
            content: Text('Kérlek, erősítsd meg az email címedet!'),
          ),
        );
        return;
      }

      // Sikeres bejelentkezés
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hiba'),
          content: Text(e.message ?? 'Ismeretlen hiba történt.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // Image.asset('assets/images/signin_balls.png'),
              const SizedBox(
                height: 50,
              ),
              const SizedBox(
                height: 50,
              ),
              Text(
                AppLocalizations.of(context)!.signIn,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              SocialButton(
                iconPath: 'assets/svgs/g_logo.svg',
                label: AppLocalizations.of(context)!.continueWithGoogle,
                buttonOnPressed: () async {
                  if (!await hasInternetConnection()) {
                    showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        title: Text("Hálózati hiba"),
                        content: Text("Nincs internetkapcsolat."),
                      ),
                    );
                    return;
                  }

                  try {
                    final userCredential =
                        await googleAuthService.signInWithGoogle();
                    if (userCredential != null) {
                      if (!mounted) return;
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  } catch (e) {
                    if (!mounted) return;
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hiba'),
                        content: Text(e.toString()),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                AppLocalizations.of(context)!.or,
                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              LoginField(
                controller: emailController,
                hideText: false,
                buttonLabelText: AppLocalizations.of(context)!.username,
                hintText: AppLocalizations.of(context)!.enterYourUsername,
              ),
              const SizedBox(
                height: 13,
              ),
              LoginField(
                controller: passwordController,
                hideText: true,
                buttonLabelText: AppLocalizations.of(context)!.password,
                hintText: AppLocalizations.of(context)!.enterYourPassword,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    if (!await hasInternetConnection()) {
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          title: Text("Hálózati hiba"),
                          content: Text("Nincs internetkapcsolat."),
                        ),
                      );
                      return;
                    }

                    final email = emailController.text.trim();

                    if (email.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          title: Text("Hiányzó email"),
                          content: Text("Kérlek, add meg az email címed!"),
                        ),
                      );
                      return;
                    }

                    try {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: email);
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          title: Text("Email elküldve"),
                          content: Text(
                              "Jelszó-visszaállító linket küldtünk az email címedre."),
                        ),
                      );
                    } on FirebaseAuthException catch (e) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Hiba"),
                          content:
                              Text(e.message ?? "Ismeretlen hiba történt."),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Elfelejtetted a jelszavad?",
                    style: TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(
                height: 65,
              ),
              GradientButton(
                buttonMargin: 20,
                text: AppLocalizations.of(context)!.logIN,
                onPressed: () async {
                  await loginUserWithEmailAndPassword();
                },
              ),
              GradientButton(
                buttonMargin: 8,
                text: "Continue as a Guest",
                onPressed: () async {
                  if (!await hasInternetConnection()) {
                    showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        title: Text("Hálózati hiba"),
                        content: Text("Nincs internetkapcsolat."),
                      ),
                    );
                    return;
                  }

                  final credential =
                      await FirebaseAuth.instance.signInAnonymously();
                  final userId = credential.user!.uid;

                  final existingDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get();

                  if (!existingDoc.exists) {
                    final guests = await FirebaseFirestore.instance
                        .collection('users')
                        .where('userinfo.username',
                            isGreaterThanOrEqualTo: 'Guest#')
                        .get();
                    final guestNumber =
                        (guests.docs.length + 1).toString().padLeft(3, '0');
                    final generatedUsername = 'Guest#$guestNumber';

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .set({
                      'userinfo': {
                        'username': generatedUsername,
                        'isUsernameChanged': true,
                        'profileImage': "",
                        'email': "",
                        'role': 'guest',
                        'createdAt': Timestamp.now(),
                      },
                      'messages': [],
                      'calendar': [],
                      'mood': [],
                      'settings': {
                        'notificationsEnabled': false,
                        'preferredLangugae': 'hu',
                        'preferredTheme': 'light',
                      },
                      'articles': [],
                    });
                  }

                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, RegisterScreen.route());
                },
                child: RichText(
                  text: TextSpan(
                    text: AppLocalizations.of(context)!.dontHaveAnAccount,
                    style: Theme.of(context).textTheme.titleMedium,
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context)!.signUp,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
