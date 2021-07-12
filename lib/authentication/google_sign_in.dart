import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  // accessing the user information
  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    final googleUser = await googleSignIn.signIn();
    if(googleUser==null)return;
    _user  =googleUser;

    final googleAuth = await user.authentication;
    // getting the credentials
    final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
    );

    // using the credentials to sign in FirebaseAuth
    await FirebaseAuth.instance.signInWithCredential(credential);

    // to update the UI
    notifyListeners();
  }

  Future<void> signOut() async {
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    return await 
    FirebaseAuth.instance.signOut();
  }
}
