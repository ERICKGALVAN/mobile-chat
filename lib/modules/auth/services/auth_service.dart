import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/modules/auth/services/database_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future loginWithEmail(String email, String password) async {
    try {
      User user = (await _auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;
      log(user.toString());
      return user.email;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        log('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        log('Wrong password provided for that user.');
      }
      return null;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future registerWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      User user = (await _auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;

      await DatabaseService(uid: user.uid).updateUserData(name, email, '');
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        log('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        log('The account already exists for that email.');
      }
      return e.code;
    } catch (e) {
      log(e.toString());
      return e.toString();
    }
  }

  Future<bool> googleAuth() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        assert(!user.isAnonymous);

        final User? currentUser = _auth.currentUser;
        await DatabaseService(uid: user.uid)
            .updateUserData(user.displayName, user.email, user.photoURL);

        assert(user.uid == currentUser!.uid);
        prefs.setString('name', user.displayName!);
        prefs.setString('email', user.email!);
        prefs.setString('photoUrl', user.photoURL!);
        prefs.setBool('isActive', true);
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isActive', false);
    await _auth.signOut();
    //await _googleSignIn.signOut();
    prefs.setString('name', '');
    prefs.setString('email', '');
    prefs.setString('photoUrl', '');
  }
}
