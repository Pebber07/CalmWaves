import "package:calmwaves_app/pages/register_screen.dart";
import "package:calmwaves_app/widgets/gradient_button.dart";
import "package:calmwaves_app/widgets/login_field.dart";
import "package:calmwaves_app/widgets/social_button.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

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

  Future<void> loginUserWithEmailAndPassword() async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      print(userCredential);
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Image.asset('assets/images/signin_balls.png'),
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
              const SocialButton(
                  iconPath: 'assets/svgs/g_logo.svg',
                  label: 'Continue with Google'),
              const SizedBox(
                height: 20,
              ),
              const SocialButton(
                iconPath: 'assets/svgs/f_logo.svg',
                label: 'Continue with Facebook',
                horizontalPaddding: 40,
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                'or',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              LoginField(
                controller: emailController,
                hintText: 'Email',
              ),
              const SizedBox(
                height: 15,
              ),
              LoginField(
                controller: passwordController,
                hintText: 'Password',
              ),
              const SizedBox(
                height: 20,
              ),
              GradientButton(
                text: "Log In",
                onPressed: () async {
                  await loginUserWithEmailAndPassword();
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
