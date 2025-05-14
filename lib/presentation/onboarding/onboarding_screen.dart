import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/auth_screen.dart';
import '../../utils/constants.dart';
import '../../utils/extensions.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const routeName = '/${Constants.onboarding}';

  Future<void> openLink(BuildContext context, String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      context.showCustomSnackBar(Constants.error, "Could not launch".tr());
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(Constants.cornerRadiusLarge),
                bottomRight: Radius.circular(Constants.cornerRadiusLarge),
              ),
              child: Image.asset(
                "assets/images/onboarding.png",
                width: MediaQuery.of(context).size.width,
                height: 422,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter
              ),
            ),
            SizedBox(height: 48),
            Image.asset(
                'assets/images/logo_light.png',
                width: 96,
                height: 96
            ),
            SizedBox(height: 16),
            Text('Voux', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.black)),
            SizedBox(height: 12),
            Text("Your fashion companion\nfor every occasion", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black87), textAlign: TextAlign.center),
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
            SizedBox(height: 32),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                  children: [
                    TextSpan(text: "By signing up, you agree to our\n"),
                    TextSpan(text: "Terms of Service ",
                        style: TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => openLink(context, "https://google.com")
                    ),
                    TextSpan(text: "and "),
                    TextSpan(text: "Privacy Policy",
                        style: TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => openLink(context, "https://google.com")
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
