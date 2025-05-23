
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  bool validatePassword(String password) {
    final hasUppercase = password.contains(RegExp(r"[A-Z]"));
    final hasSpecialCharacter = password.contains(RegExp(r"[!@#\$%^&*(),.:{}|<>]"));
    final hasMinLength = password.length >= 6;
    return hasUppercase && hasSpecialCharacter && hasMinLength;
  }

    // Login email + password.
  Future<Map<String, dynamic>> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    final loc = AppLocalizations.of(context)!;

    if (email.isEmpty || password.isEmpty) {
      return {'success': false, 'error': loc.fillAllFields};
    }

    try {
      final userCredential =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if (user == null) {
        return {'success': false, 'error': loc.unknownError};
      }
      if (!user.emailVerified) {
        return {'success': false, 'error': loc.confirmEmail};
      }
      return {'success': true, 'user': user};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': e.message ?? loc.unknownError};
    }
  }

  // Register.
  Future<Map<String, dynamic>> register({
    required BuildContext context,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final loc = AppLocalizations.of(context)!;

    if ([username, email, password, confirmPassword].any((element) => element.trim().isEmpty)) {
      return {'success': false, 'error': loc.fillAllFields};
    }

    if (password != confirmPassword) {
      return {'success': false, 'error': loc.passwordsNotMatching};
    }

    if (!validatePassword(password)) {
      return {'success': false, 'error': loc.weakPassword};
    }

    if (username.startsWith("Guest#")) {
      return {'success': false, 'error': loc.guestNotChoose};
    }

    final usernameTaken = await _firestore
        .collection("users")
        .where("userinfo.username", isEqualTo: username)
        .get();
    if (usernameTaken.docs.isNotEmpty) {
      return {'success': false, 'error': loc.usernameAlreadyUsed};
    }

    try {
      final userCredential =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user?.sendEmailVerification();

      final defaultImageRef =
          _storage.ref().child('profile_pictures/template_profile_picture.png');
      final defaultImageUrl = await defaultImageRef.getDownloadURL();

      final userId = userCredential.user!.uid;
      await _firestore.collection('users').doc(userId).set({
        'userinfo': {
          'username': username,
          'isUsernameChanged': false,
          'profileImage': defaultImageUrl,
          'email': email,
          'role': 'user',
          'createdAt': Timestamp.now(),
        },
        'messages': [],
        'calendar': [],
        'mood': [],
        'settings': {
          'notificationsEnabled': true,
          'preferredLangugae': 'hu',
          'preferredTheme': 'light',
        },
        'articles': [],
      });

      return {'success': true, 'user': userCredential.user};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': e.message ?? loc.unknownError};
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<bool> loginAsGuest(BuildContext context) async {
    try {
      final credential = await _auth.signInAnonymously();
      final userId = credential.user!.uid;

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        final defaultImageRef =
            _storage.ref().child('profile_pictures/template_profile_picture.png');
        final defaultImageUrl = await defaultImageRef.getDownloadURL();

        final guestsQuery = await _firestore
            .collection('users')
            .where('userinfo.username', isGreaterThanOrEqualTo: 'Guest#')
            .get();

        final guestNumber =
            (guestsQuery.docs.length + 1).toString().padLeft(3, '0');
        final generatedUsername = 'Guest#$guestNumber';

        await _firestore.collection('users').doc(userId).set({
          'userinfo': {
            'username': generatedUsername,
            'isUsernameChanged': true,
            'profileImage': defaultImageUrl,
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

      return true;
    } catch (_) {
      return false;
    }
  }
}