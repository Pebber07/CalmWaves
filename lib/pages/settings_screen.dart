import "package:calmwaves_app/palette.dart";
import "package:calmwaves_app/widgets/custom_app_bar.dart";
import "package:calmwaves_app/widgets/custom_drawer.dart";
import "package:calmwaves_app/widgets/gradient_button.dart";
import "package:calmwaves_app/widgets/login_field.dart";
import "package:calmwaves_app/widgets/social_button.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:fluttertoast/fluttertoast.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  TextEditingController newUsernameController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool usernameChanged = false;

  Future<String> getOldPassword(String userId) async {
    final userDoc = FirebaseFirestore.instance.collection("users").doc(userId);
    final docSnapshot = await userDoc.get();
    if (docSnapshot.exists) {
      return docSnapshot.data()?["userinfo"]["password"] ?? "";
    } else {
      return ""; // This document doesn't exists.
    }
  }

  void _onSaveChanges(BuildContext context, String userId) async {
    String oldPassword = oldPasswordController.text.trim();
    String newPassword = newPasswordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    // Get current user to reauthenticate
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Fluttertoast.showToast(
        msg: "Nincs bejelentkezve felhasználó!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    // Reauthenticate user to confirm old password
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);

      bool confirmChange = await _showConfirmationDialog(context);
      if (confirmChange) {
        await _updatePassword(newPassword);
        Fluttertoast.showToast(
          msg: "A jelszó sikeresen megváltozott!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Hiba történt a jelszó ellenőrzésekor vagy frissítésekor!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Biztos vagy benne?"),
              content: const Text("Biztosan meg akarod változtatni a jelszót?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("Nem"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Igen"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _updatePassword(String newPassword) async {
     User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await user.updatePassword(newPassword);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Hiba történt a jelszó frissítésekor!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _deleteAccount(BuildContext context, String userId) async {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection("userid").doc(userId);
      await userDoc.delete();
      await FirebaseAuth.instance.currentUser?.delete();
      Fluttertoast.showToast(
          msg: "Fiók törölve!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      Navigator.pushReplacementNamed(context, "/login");
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Hiba történt a törlés során!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      Fluttertoast.showToast(
        msg: "Signing off...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, "/login");
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Hiba történt a kijelentkezés során!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                    "assets/images/own_profile_pic.jpg"), // felhasználó dokumentumából kell származnia.
              ),
              const Text(
                "CalmWaves",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),
              const InkWell(
                child: Text(
                  "calmwaves@support.com",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ), //does it needed?
              const SizedBox(
                height: 20,
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 10),
                child: const Text(
                  "Update Your Account",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),

              LoginField(
                  hintText: "Enter your new username",
                  controller: newUsernameController,
                  hideText: false,
                  buttonLabelText: "New username"),
              const SizedBox(
                height: 10,
              ), // only once
              LoginField(
                  hintText: "Enter your old password",
                  controller: oldPasswordController,
                  hideText: true,
                  buttonLabelText: "Old password"),
              const SizedBox(
                height: 10,
              ),
              LoginField(
                  hintText: "Enter your new password",
                  controller: newPasswordController,
                  hideText: true,
                  buttonLabelText: "New password"),
              const SizedBox(
                height: 10,
              ),
              LoginField(
                  hintText: "Enter your new password again",
                  controller: confirmPasswordController,
                  hideText: true,
                  buttonLabelText: "New password again"),
              const SizedBox(
                height: 10,
              ),

              GradientButton(
                  onPressed: () => _onSaveChanges(context, userId),
                  text:
                      "Save Changes", 
                  buttonMargin: 5),
              // GradientButton(
              //     onPressed: () => _deleteAccount(context, userId),
              //     text:
              //         "Delete Account", // If someone presses on it, then it deletes the users whole profile.
              //     buttonMargin: 5),
              GradientButton(
                  onPressed: () async {
                    await _signOut(context);
                  },
                  text: "Sign Out",
                  buttonMargin: 5),
            ],
          ),
        ),
      ),
    );
  }
}
