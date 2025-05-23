import 'package:calmwaves_app/services/auth_service.dart';
import 'package:calmwaves_app/services/google_auth.dart';
import 'package:calmwaves_app/widgets/check_internet.dart';
import 'package:calmwaves_app/widgets/gradient_button.dart';
import 'package:calmwaves_app/widgets/custom_text_field.dart';
import 'package:calmwaves_app/widgets/social_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:calmwaves_app/pages/register_screen.dart';

/// Login screen where the already registered, and guest users can enter the application.
class LoginScreen extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!await hasInternetConnection()) {
      _showErrorDialog(AppLocalizations.of(context)!.noInternetConnection,
          AppLocalizations.of(context)!.connectNetwork);
      return;
    }

    final result = await _authService.login(
      context: context,
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (result['success']) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showErrorDialog(AppLocalizations.of(context)!.error, result['error']);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
      ),
    );
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final loc = AppLocalizations.of(context)!;

    if (!await hasInternetConnection()) {
      _showErrorDialog(loc.networkError, loc.noInternetConnection);
      return;
    }

    if (email.isEmpty) {
      _showErrorDialog(loc.emailEmpty, loc.enterYourEmail);
      return;
    }

    try {
      await AuthService().sendPasswordResetEmail(email);
      _showErrorDialog(loc.emailSent, loc.getBackPassword);
    } catch (e) {
      _showErrorDialog(loc.error, e.toString());
    }
  }

  Future<void> _loginAsGuest() async {
    if (!await hasInternetConnection()) {
      _showErrorDialog(
        AppLocalizations.of(context)!.networkError,
        AppLocalizations.of(context)!.noInternetConnection,
      );
      return;
    }

    final success = await _authService.loginAsGuest(context);
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _signInWithGoogle() async {
    if (!await hasInternetConnection()) {
      _showErrorDialog(
        AppLocalizations.of(context)!.networkError,
        AppLocalizations.of(context)!.noInternetConnection,
      );
      return;
    }

    try {
      final userCredential = await _googleAuthService.signInWithGoogle();
      if (userCredential != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _showErrorDialog(
        AppLocalizations.of(context)!.error,
        e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 75),
                Text(
                  loc.signIn,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
                const SizedBox(height: 50),
                SocialButton(
                  iconPath: 'assets/svgs/g_logo.svg',
                  label: loc.continueWithGoogle,
                  buttonOnPressed: _signInWithGoogle,
                ),
                const SizedBox(height: 10),
                Text(loc.or, style: const TextStyle(fontSize: 17)),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _emailController,
                  hideText: false,
                  buttonLabelText: loc.email,
                  hintText: loc.enterYourEmail,
                ),
                const SizedBox(height: 13),
                CustomTextField(
                  controller: _passwordController,
                  hideText: true,
                  buttonLabelText: loc.password,
                  hintText: loc.enterYourPassword,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    child: Text(
                      loc.forgotYourPassword,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                GradientButton(
                  buttonMargin: 20,
                  text: loc.logIN,
                  onPressed: _handleLogin,
                ),
                GradientButton(
                  buttonMargin: 8,
                  text: loc.continueAsAGuest,
                  onPressed: _loginAsGuest,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, RegisterScreen.route());
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "${loc.dontHaveAnAccount} ",
                      style: Theme.of(context).textTheme.titleMedium,
                      children: [
                        TextSpan(
                          text: loc.signUp,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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