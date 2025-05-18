import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleAuthService {
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid);
      final docSnapshot = await userRef.get();

      if (!docSnapshot.exists) {
        // Ha nem létezik a felhasználó, hozd létre az adatokat
        await userRef.set({
          'userinfo': {
            'username': userCredential.user!.displayName ?? 'No Name',
            'email': userCredential.user!.email,
          },
          'articles': [],
          'messages': [],
          'calendar': [],
          'mood': [],
          'settings': {'notificationsEnabled': true},
        });
      }
      return userCredential;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error during Google Sign In",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      rethrow;
    }
  }
}
