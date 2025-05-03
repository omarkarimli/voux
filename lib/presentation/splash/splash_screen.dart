import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voux/presentation/home/home_screen.dart';
import '../../firebase_options.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../home/home_view_model.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const routeName = '/${Constants.splash}';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<void> _startApp() async {
    // Wait 3 seconds
    await Future.delayed(const Duration(seconds: 4));
    bool isLoggedIn = await _initializeApp();

    // Navigate based on login state
    if (mounted) {
      Navigator.pushReplacementNamed(
          context,
          isLoggedIn ? HomeScreen.routeName : OnboardingScreen.routeName
      );
    }
  }

  Future<bool> _initializeApp() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    return _getLoginState();
  }

  Future<bool> _getLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Constants.isLoggedIn) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/splash_logo.png',
          width: 320,
          height: 320,
        )
      ),
    );
  }
}
