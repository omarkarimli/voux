import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme/theme.dart';
import 'theme/theme_util.dart';

import 'utils/constants.dart';
import 'presentation/onboarding/onboarding_screen.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/home/home_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Define a common fade transition
  PageRouteBuilder _fadeTransitionRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0; // Start opacity for the fade
        const end = 1.0;   // End opacity for the fade
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var opacityAnimation = animation.drive(tween);

        return FadeTransition(opacity: opacityAnimation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness; // Fix here

    TextTheme textTheme = createTextTheme(context, "Poppins", "Poppins");

    MaterialTheme theme = MaterialTheme(textTheme);
    return MaterialApp(
      title: Constants.appName,
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      home: OnboardingScreen(),
      onGenerateRoute: (settings) {
        print('Navigating to: ${settings.name}');
        switch (settings.name) {
          case HomeScreen.routeName:
            return _fadeTransitionRoute(
              BlocProvider(
                create: (context) => HomeBloc(),
                child: HomeScreen(),
              ),
            );
          default:
            print('No route found for: ${settings.name}');
            return null;
        }
      },
    );
  }
}