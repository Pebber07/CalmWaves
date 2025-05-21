import "dart:ffi";

import "package:calmwaves_app/widgets/custom_app_bar.dart";
import "package:calmwaves_app/widgets/custom_drawer.dart";
import "package:calmwaves_app/widgets/gradient_button.dart";
import "package:calmwaves_app/widgets/language_selector_widget.dart";
import "package:calmwaves_app/widgets/login_field.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:fluttertoast/fluttertoast.dart";
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import "package:workmanager/workmanager.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final void Function(Locale) setLocale;
  final void Function(bool) toggleTheme;

  const SettingsScreen(
      {super.key, required this.setLocale, required this.toggleTheme});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  TextEditingController newUsernameController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isUsernameChanged = false;
  bool isDarkTheme = false;
  bool _isGuest = false;
  Map<String, dynamic>? notificationSettings;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!doc.exists) return;

    final data = doc['userinfo'];
    final settings = doc['settings'];
    final role = data['role'] ?? 'user';
    final isGuest = role == 'guest';

    setState(() {
      isUsernameChanged = data['isUsernameChanged'] ?? true;
      isDarkTheme = (settings['theme'] ?? 'light') == 'dark';
      _isGuest = isGuest;
      notificationSettings = settings;
    });
  }

  Future<void> _changeUsername() async {
    final newUsername = newUsernameController.text.trim();
    if (newUsername.isEmpty) return;

    final isTaken = await FirebaseFirestore.instance
        .collection('users')
        .where('userinfo.username', isEqualTo: newUsername)
        .get();
    if (isTaken.docs.isNotEmpty) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.usernameAlreadyUsed);
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'userinfo.username': newUsername,
      'userinfo.isUsernameChanged': true,
    });

    setState(() {
      isUsernameChanged = true;
    });

    Fluttertoast.showToast(msg: AppLocalizations.of(context)!.usernameUpdated);
  }

  Future<void> _changePassword() async {
    final oldPass = oldPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (newPass != confirmPass) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.passwordsNotMatching);
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final credential =
          EmailAuthProvider.credential(email: user.email!, password: oldPass);
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPass);
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.passwordUpdated);
    } catch (e) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.errorDuringPassword);
    }
  }

  Future<void> _updateTheme(bool isDark) async {
    setState(() {
      isDarkTheme = isDark;
    });

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'settings.theme': isDark ? 'dark' : 'light',
    });
  }

  void launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'tapodinorman7@gmail.com',
      query: Uri.encodeFull('subject=Támogatás&body=Kérdés/Kérés szövege:'),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      Fluttertoast.showToast(msg: AppLocalizations.of(context)!.errorEmailOpen);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(AppLocalizations.of(context)!.userProfileSettings,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            if (!isUsernameChanged && !_isGuest) ...[
              CustomTextField(
                hintText: AppLocalizations.of(context)!.newUsername,
                controller: newUsernameController,
                hideText: false,
                buttonLabelText: AppLocalizations.of(context)!.newUsername,
              ),
              GradientButton(
                onPressed: _changeUsername,
                text: AppLocalizations.of(context)!.saveNewUsername,
                buttonMargin: 8,
              ),
            ] else
              Text(AppLocalizations.of(context)!.usernameAlreadyUpdated,
                  style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            const Divider(),
            if (!_isGuest) ...[
              Text(AppLocalizations.of(context)!.modifyPassword,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              CustomTextField(
                hintText: AppLocalizations.of(context)!.currentPasword,
                controller: oldPasswordController,
                hideText: true,
                buttonLabelText: AppLocalizations.of(context)!.oldPassword,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                hintText: AppLocalizations.of(context)!.newPassword,
                controller: newPasswordController,
                hideText: true,
                buttonLabelText: AppLocalizations.of(context)!.newPasswordAgain,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                hintText: AppLocalizations.of(context)!.newPasswordAgain,
                controller: confirmPasswordController,
                hideText: true,
                buttonLabelText: AppLocalizations.of(context)!.newPasswordAgain,
              ),
              GradientButton(
                onPressed: _changePassword,
                text: AppLocalizations.of(context)!.refreshPassword,
                buttonMargin: 8,
              ),
              const SizedBox(height: 10),
              const Divider(),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.darkMode,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: isDarkTheme,
                  onChanged: (bool newValue) {
                    setState(() {
                      isDarkTheme = newValue;
                    });
                    widget.toggleTheme(newValue);
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .update(
                            {'settings.theme': newValue ? 'dark' : 'light'});
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.notifications,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: !_isGuest &&
                      (notificationSettings?['notificationsEnabled'] ?? true),
                  onChanged: _isGuest
                      ? null
                      : (bool newValue) async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .update(
                                  {'settings.notificationsEnabled': newValue});

                          setState(() {
                            notificationSettings?['notificationsEnabled'] =
                                newValue;
                          });

                          if (newValue) {
                            Workmanager().registerPeriodicTask(
                              "dailyQuoteTaskId",
                              "dailyQuoteTask",
                              frequency: const Duration(hours: 24),
                              initialDelay: Duration(
                                hours: (8 - DateTime.now().hour) % 24,
                              ),
                              existingWorkPolicy: ExistingWorkPolicy.keep,
                            );
                          } else {
                            Workmanager()
                                .cancelByUniqueName("dailyQuoteTaskId");
                          }
                        },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.appLanguage,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 16,
            ),
            Center(
              child: LanguageSelector(
                initialLanguage: "hu",
                onLanguageSelected: (langCode) {
                  widget.setLocale(
                    Locale(langCode),
                  );
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .update({'settings.preferredLanguage': langCode});
                },
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(AppLocalizations.of(context)!.contactUs,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Center(
              child: InkWell(
                onTap: () => launchEmail(),
                child: const Text(
                  "support@calmwaves.com",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
