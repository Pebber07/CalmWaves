import 'package:calmwaves_app/services/auth_service.dart';
import 'package:calmwaves_app/services/google_auth.dart';
import 'package:calmwaves_app/widgets/check_internet.dart';
import 'package:calmwaves_app/widgets/gradient_button.dart';
import 'package:calmwaves_app/widgets/custom_text_field.dart';
import 'package:calmwaves_app/widgets/social_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:calmwaves_app/pages/login_screen.dart';

/// Registration screen, email - password, or with Google account.
class RegisterScreen extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      );

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _googleAuthService = GoogleAuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!await hasInternetConnection()) {
      _showDialog(AppLocalizations.of(context)!.noInternetConnection,
          AppLocalizations.of(context)!.connectNetwork);
      return;
    }

    final result = await _authService.register(
      context: context,
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
    );

    if (!mounted) return;

    if (result['success']) {
      _showDialog(
        AppLocalizations.of(context)!.successfullRegister,
        AppLocalizations.of(context)!.confirmEmail,
        actionText: AppLocalizations.of(context)!.enter,
        onActionPressed: () {
          Navigator.pushReplacement(context, LoginScreen.route());
        },
      );
    } else {
      _showDialog(AppLocalizations.of(context)!.error, result['error']);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (!await hasInternetConnection()) {
      _showDialog(
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
      _showDialog(AppLocalizations.of(context)!.error, e.toString());
    }
  }

  void _showDialog(String title, String content,
      {String? actionText, VoidCallback? onActionPressed}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actionText != null
            ? [
                TextButton(
                  onPressed: onActionPressed,
                  child: Text(actionText),
                ),
              ]
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 75),
                  Text(
                    loc.register,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                  const SizedBox(height: 35),
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
                    hintText: 'someone@example.com',
                  ),
                  const SizedBox(height: 13),
                  CustomTextField(
                    controller: _usernameController,
                    hideText: false,
                    buttonLabelText: loc.username,
                    hintText: 'MentalKing02',
                  ),
                  const SizedBox(height: 13),
                  CustomTextField(
                    controller: _passwordController,
                    hideText: true,
                    buttonLabelText: loc.password,
                    hintText: 'SecurePassword!123',
                  ),
                  const SizedBox(height: 13),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    hideText: true,
                    buttonLabelText: loc.passwordAgain,
                    hintText: 'SecurePassword!123',
                  ),
                  const SizedBox(height: 35),
                  GradientButton(
                    buttonMargin: 15,
                    text: loc.register,
                    onPressed: _handleRegister,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, LoginScreen.route());
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "${loc.alreadyAMember} ",
                        style: Theme.of(context).textTheme.titleMedium,
                        children: [
                          TextSpan(
                            text: loc.signIn,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
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
      ),
    );
  }
}