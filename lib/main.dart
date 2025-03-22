import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme/theme.dart';
import 'theme/theme_util.dart';

import 'utils/constants.dart';
import 'presentation/onboarding/onboarding_screen.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/home/home_bloc.dart';
import 'presentation/anim/anim_transition_route.dart';
import 'presentation/auth/auth_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;

    TextTheme textTheme = createTextTheme(context, "Poppins", "Poppins");

    MaterialTheme theme = MaterialTheme(textTheme);
    return MaterialApp(
      title: Constants.appName,
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      home: AuthScreen(),
      onGenerateRoute: (settings) {
        print('Navigating to: ${settings.name}');
        switch (settings.name) {
          case HomeScreen.routeName:
            return animTransitionRoute(
              BlocProvider(
                create: (context) => HomeBloc(),
                child: HomeScreen(),
              ),
            );
          case OnboardingScreen.routeName:
            return animTransitionRoute(
              OnboardingScreen(),
            );
          default:
            print('No route found for: ${settings.name}');
            return null;
        }
      },
    );
  }
}