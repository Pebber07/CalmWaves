import "package:calmwaves_app/pages/login_screen.dart";
import "package:calmwaves_app/services/google_auth.dart";
import "package:calmwaves_app/widgets/check_internet.dart";
import "package:calmwaves_app/widgets/gradient_button.dart";
import "package:calmwaves_app/widgets/language_selector_widget.dart";
import "package:calmwaves_app/widgets/login_field.dart";
import "package:calmwaves_app/widgets/social_button.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:google_sign_in/google_sign_in.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      );
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  final googleAuthService = GoogleAuthService();

  bool areFieldsFilled() {
    return emailController.text.trim().isNotEmpty &&
        usernameController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty &&
        confirmPasswordController.text.trim().isNotEmpty;
  }

  // Felhasználónév ellenőrzése (létezik-e).
  Future<bool> isUsernameTaken(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("userinfo.username", isEqualTo: username)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  // Jelszó megfelelő-e.
  bool validatePassword(String password) {
    final hasUppercase = password.contains(RegExp(r"[A-Z]"));
    final hasSpecialCharacter =
        password.contains(RegExp(r"[!@#$%^&*(),.:{}|<>]"));
    final hasMinLength = password.length >= 6;
    return hasUppercase && hasSpecialCharacter && hasMinLength;
  }

  Future<void> createUserWithEmailAndPassword() async {
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

    if (!formKey.currentState!.validate()) return;

    try {
      final isTaken = await isUsernameTaken(usernameController.text.trim());
      if (isTaken) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text('Hiba'),
            content: Text('Ez a felhasználónév már foglalt.'),
          ),
        );
        return;
      }

      final username = usernameController.text.trim();
      if (username.startsWith("Guest#")) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text("Hiba"),
            content:
                Text("A 'Guest#' kezdetű felhasználónevek nem választhatók."),
          ),
        );
        return;
      }

      // Felhasználó létrehozása
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Email megerősítés küldése
      await userCredential.user?.sendEmailVerification();

      // Firestore dokumentum létrehozása
      final userId = userCredential.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'userinfo': {
          'username': usernameController.text.trim(),
          'isUsernameChanged': false,
          //'profilePicture': "", Todo: Download a template Profile picture.
          'profileImage': "",
          'email': emailController.text.trim(),
          'role': 'user',
          'createdAt': Timestamp.now(),
        },
        'messages': [],
        'calendar': [],
        'mood': [],
        'settings': {
          'notificationsEnabled': true,
          'preferredLangugae': 'hu',
          'preferredTheme': 'light'
        },
        'articles': [],
      });

      // Regisztráció sikeres üzenet
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sikeres regisztráció'),
          content: const Text(
              'Erősítsd meg az email címedet a regisztráció véglegesítéséhez.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.push(context, LoginScreen.route()),
              child: const Text('Belépés'),
            ),
          ],
        ),
      );
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
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                const SizedBox(
                  height: 50,
                ),
                Text(
                  AppLocalizations.of(context)!.register,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
                  ),
                ),
                const SizedBox(
                  height: 35,
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
                        final user = userCredential.user!;
                        final userRef = FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid);
                        final docSnapshot = await userRef.get();

                        if (!docSnapshot.exists) {
                          // Ha új felhasználó, hozd létre az adatokat
                          await userRef.set({
                            'userinfo': {
                              'username': user.displayName ?? 'No Name',
                              'email': user.email,
                            },
                            'articles': [],
                            'messages': [],
                            'calendar': [],
                            'mood': [],
                            'settings': {'notificationsEnabled': true},
                          });
                        }

                        if (!mounted) return;
                        Navigator.pushReplacementNamed(context, '/home');
                      } else {
                        Fluttertoast.showToast(
                          msg: "Nem választott fiókot!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
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
                CustomTextField(
                  controller: emailController,
                  hideText: true,
                  buttonLabelText: AppLocalizations.of(context)!.email,
                  hintText: 'Someone@gmail.com',
                ),
                const SizedBox(
                  height: 13,
                ),
                CustomTextField(
                  controller: usernameController,
                  hideText: true,
                  buttonLabelText: AppLocalizations.of(context)!.username,
                  hintText: 'MentalKing02',
                ),
                const SizedBox(
                  height: 13,
                ),
                CustomTextField(
                  controller: passwordController,
                  hideText: false,
                  buttonLabelText: AppLocalizations.of(context)!.password,
                  hintText: 'Randompassword1010',
                ),
                const SizedBox(
                  height: 13,
                ),
                CustomTextField(
                  controller: confirmPasswordController,
                  hideText: false,
                  buttonLabelText: AppLocalizations.of(context)!.passwordAgain,
                  hintText: 'Randompassword1010',
                ),
                const SizedBox(
                  height: 10,
                ),
                GradientButton(
                  buttonMargin: 15,
                  text: AppLocalizations.of(context)!.register,
                  onPressed: () async {
                    if (!areFieldsFilled()) {
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          title: Text('Hiba'),
                          content: Text('Kérem, az összes mezőt töltse ki!'),
                        ),
                      );
                      return;
                    }

                    if (passwordController.text.trim() !=
                        confirmPasswordController.text.trim()) {
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          title: Text('Hiba'),
                          content: Text('A jelszavak nem egyeznek meg.'),
                        ),
                      );
                      return;
                    }

                    if (!validatePassword(passwordController.text.trim())) {
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          title: Text('Hiba'),
                          content: Text('A jelszó nem elég erős.'),
                        ),
                      );
                      return;
                    }
                    await createUserWithEmailAndPassword();
                  },
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, LoginScreen.route());
                  },
                  child: RichText(
                    text: TextSpan(
                      text: AppLocalizations.of(context)!.alreadyAMember,
                      style: Theme.of(context).textTheme.titleMedium,
                      children: [
                        TextSpan(
                          text: AppLocalizations.of(context)!.signIn,
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
      ),
    );
  }
}
