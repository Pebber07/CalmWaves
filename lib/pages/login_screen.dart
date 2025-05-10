import "package:calmwaves_app/pages/register_screen.dart";
import "package:calmwaves_app/services/google_auth.dart";
import "package:calmwaves_app/widgets/gradient_button.dart";
import "package:calmwaves_app/widgets/language_selector_widget.dart";
import "package:calmwaves_app/widgets/login_field.dart";
import "package:calmwaves_app/widgets/social_button.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:google_sign_in/google_sign_in.dart";

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
              /*
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: LanguageSelector(
                        initialLanguage: 'hu', onLanguageSelected: (langCode) {
                          // Translate the texts to the given language
                        }),
                  ),
                ],
              ),
              */
              const SizedBox(
                height: 50,
              ),
              const Text(
                'Sign In',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              SocialButton(
                iconPath: 'assets/svgs/g_logo.svg',
                label: 'Continue with Google',
                buttonOnPressed: () async {
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
              const Text(
                'or',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              LoginField(
                controller: emailController,
                hideText: false,
                buttonLabelText: "Username",
                hintText: 'Enter your username',
              ),
              const SizedBox(
                height: 13,
              ),
              LoginField(
                controller: passwordController,
                hideText: true,
                buttonLabelText: "Password",
                hintText: 'Enter your password',
              ),
              const SizedBox(
                height: 65,
              ),
              GradientButton(
                buttonMargin: 20,
                text: "Log In",
                onPressed: () async {
                  await loginUserWithEmailAndPassword();
                },
              ),
              GradientButton(
                buttonMargin: 8,
                text: "Continue as a Guest",
                onPressed: () async {
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
                    text: 'Don\'t have an account? ',
                    style: Theme.of(context).textTheme.titleMedium,
                    children: [
                      TextSpan(
                        text: 'Sign Up',
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
