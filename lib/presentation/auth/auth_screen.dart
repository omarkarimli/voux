import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' as apple;
import 'package:voux/presentation/home/home_screen.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../models/subscription_payment_model.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  static const routeName = '/${Constants.auth}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24),
              child: Text(
                "Voux",
                style: GoogleFonts.aboreto(
                  fontSize: 112,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            )
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).padding.bottom + 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final user = await signInWithGoogle();
                      _checkLoginState(context, user);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      padding: EdgeInsets.symmetric(vertical: 12.0)
                    ),
                    icon: Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Image.asset(
                        'assets/images/google.png',
                        width: 18,
                        height: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    label: Text(
                      "Continue with Google",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    iconAlignment: IconAlignment.start,
                  ),
                  SizedBox(height: 12.0),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final user = await signInWithApple();
                      _checkLoginState(context, user);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.onSurface,
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    icon: Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Image.asset(
                        'assets/images/apple.png',
                        width: 18,
                        height: 18,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    label: Text(
                      "Continue with Apple",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    iconAlignment: IconAlignment.start,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null; // User canceled sign-in

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential?> signInWithApple() async {
    if (!Platform.isIOS) return null;

    final credential = await apple.SignInWithApple.getAppleIDCredential(
      scopes: [apple.AppleIDAuthorizationScopes.email, apple.AppleIDAuthorizationScopes.fullName],
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: credential.identityToken,
      accessToken: credential.authorizationCode,
    );

    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _checkLoginState(BuildContext context, UserCredential? user) async {
    if (user != null) {
      print('Signed in: ${user.user?.displayName}');

      await Future.wait([
        _saveUserToFirestore(user),
        _saveLoginState(true),
      ]);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signed in as ${user.user?.displayName}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer)),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      );

      Navigator.pushNamed(context, HomeScreen.routeName);
    } else {
      print('Sign-in failed');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign-in failed', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer)),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
    }
  }

  // Function to save the login state in SharedPreferences
  Future<void> _saveLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(Constants.isLoggedIn, isLoggedIn),
      prefs.setBool(Constants.isDarkMode, false),
      prefs.setBool(Constants.canNoti, false),
    ]);
  }


  Future<void> _saveUserToFirestore(UserCredential userCredential) async {
    final user = userCredential.user;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection(Constants.users).doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      // Create a new user with an initial subscription
      Timestamp now = Timestamp.now();
      SubscriptionPaymentModel initialSubscription = SubscriptionPaymentModel(
        id: Uuid().v4(),
        name: Constants.freePlan,
        purchaseTime: now,
        endTime: Timestamp.fromDate(now.toDate().add(Duration(days: 30))),
      );

      UserModel newUser = UserModel(
        uid: user.uid,
        name: user.displayName ?? Constants.unknown,
        email: user.email ?? '',
        createdAt: now,
        currentSubscriptionStatus: Constants.freePlan,
        analysisLimit: Constants.analysisLimitCountFree,
        currentAnalysisCount: 0,
        subscriptions: [initialSubscription],
      );

      await userDoc.set(newUser.toMap());
    }
  }
}
