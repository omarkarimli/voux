import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' as apple;
import 'package:uuid/uuid.dart';

import '../../models/subscription_payment_model.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';

class AuthViewModel extends ChangeNotifier {
  final SharedPreferences prefs;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthViewModel({
    required this.prefs,
    required this.auth,
    required this.firestore,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isNavigateToHome = false;
  bool get navigateToHome => _isNavigateToHome;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void setNavigateToHomeScreen(bool value) {
    _isNavigateToHome = value;
    notifyListeners();
  }

  Future<UserCredential?> signInWithGoogle() async {
    setLoading(true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await auth.signInWithCredential(credential);
      await saveUserToFirestore(userCredential);
      return userCredential;
    } catch (e) {
      setError('Google sign-in failed: ${e.toString()}');
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<UserCredential?> signInWithApple() async {
    setLoading(true);
    if (!Platform.isIOS) return null;

    try {

      final credential = await apple.SignInWithApple.getAppleIDCredential(
        scopes: [
          apple.AppleIDAuthorizationScopes.email,
          apple.AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential = await auth.signInWithCredential(oauthCredential);
      await saveUserToFirestore(userCredential);
      return userCredential;
    } catch (e) {
      setError('Apple sign-in failed: ${e.toString()}');
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<void> saveUserToFirestore(UserCredential userCredential) async {
    setLoading(true);

    final user = userCredential.user;
    if (user == null) return;

    try {
      final userDoc = firestore.collection(Constants.users).doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        final now = Timestamp.now();

        final initialSubscription = SubscriptionPaymentModel(
          id: const Uuid().v4(),
          name: Constants.freePlan,
          purchaseTime: now,
          endTime: Timestamp.fromDate(
            now.toDate().add(const Duration(days: 30)),
          ),
        );

        final newUser = UserModel(
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
        if (kDebugMode) {
          print("✅ New user created: ${user.uid}");
        }
      } else {
        if (kDebugMode) {
          print("ℹ️ User already exists: ${user.uid}");
        }
      }

      await saveLoginState(true);
    } catch (e) {
      setError("Failed to save user: ${e.toString()}");
      if (kDebugMode) {
        print("❌ Firestore error: $e");
      }
    } finally {
      setLoading(false);
    }
  }

  // Function to save the login state in SharedPreferences
  Future<void> saveLoginState(bool isLoggedIn) async {
    await Future.wait([
      prefs.setBool(Constants.isLoggedIn, isLoggedIn),
      prefs.setString(Constants.notification, Constants.notificationSystem)
    ]);

    setNavigateToHomeScreen(true);
  }
}
