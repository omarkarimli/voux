import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import '../detail/stacked_avatar_badge.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const routeName = '/${Constants.onboarding}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: MediaQuery.of(context).padding.top + 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Column(
                children: [
                  SizedBox(height: 32),
                  Text(
                    "Voux",
                    style: GoogleFonts.aboreto(
                      textStyle: Theme.of(context).textTheme.displayMedium,
                      letterSpacing: 2.0,
                    ),
                  ),
                  SizedBox(height: 32),
                  Card(
                      color: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      clipBehavior: Clip.antiAlias,
                      elevation: 3,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    StackedAvatarBadge(profileImage: "assets/images/woman_avatar.png", badgeImage: "assets/images/sparkle.png", badgeSize: 32),
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Theme.of(context).colorScheme.surface,
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.arrow_outward_rounded, color: Theme.of(context).colorScheme.onSurface),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 22),
                                Container(
                                  width: double.infinity,
                                  height: 192,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    image: DecorationImage(
                                      image: AssetImage('assets/images/card_bg_1.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 22),
                                Padding(
                                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("AI-Powered", style: Theme.of(context).textTheme.bodyLarge),
                                        SizedBox(height: 4),
                                        Text("Discover fashion\ninsights from your\nwardrobe", style: Theme.of(context).textTheme.headlineMedium),
                                      ],
                                    )
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              HomeScreen.routeName,
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.onSurface,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 12),
                                            child: Text("Get Started", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.surface)),
                                          )
                                      )
                                  )
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                  ),
                  SizedBox(height: 32),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "© ",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            TextSpan(
                              text: "Developed by Omar",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )
            )
          )
        ],
      )
    );
  }
}
