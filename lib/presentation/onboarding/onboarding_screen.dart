import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../auth/auth_screen.dart';
import '../../utils/constants.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const routeName = '/${Constants.onboarding}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/images/collage.png', width: MediaQuery.of(context).size.width, fit: BoxFit.cover),
            SizedBox(height: 32),
            Image.asset('assets/images/logo_light.png', width: 96, height: 96),
            SizedBox(height: 16),
            Text('Voux', style: Theme.of(context).textTheme.headlineLarge),
            SizedBox(height: 12),
            Text("Your fashion companion\nfor every occasion", style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
            SizedBox(height: 32),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, AuthScreen.routeName);
                  },
                  child: Text(
                    'Get Started',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(text: "By signing up, you agree to our\n"),
                    TextSpan(text: "Terms of Service ",
                        style: TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // TODO: Open Terms of Service page
                            print("Terms of Service clicked!");
                          }
                    ),
                    TextSpan(text: "and "),
                    TextSpan(text: "Privacy Policy",
                        style: TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // TODO: Open Privacy Policy page
                            print("Privacy Policy clicked!");
                          }
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 48)
          ],
        )
      )
    );
  }
}
