import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voux/presentation/splash/splash_screen.dart';
import 'theme/theme.dart';
import 'theme/theme_util.dart';
import 'utils/constants.dart';
import 'presentation/onboarding/onboarding_screen.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/home/home_bloc.dart';
import 'presentation/anim/anim_transition_route.dart';
import 'presentation/auth/auth_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: SplashScreen(),
      onGenerateRoute: (settings) { return _onGenerateRoute(settings); },
    );
  }

  PageRouteBuilder? _onGenerateRoute(RouteSettings settings) {
    print('Navigating to: ${settings.name}');
    switch (settings.name) {
      case HomeScreen.routeName:
        return animTransitionRoute(const HomeScreenWithBloc());
      case OnboardingScreen.routeName:
        return animTransitionRoute(const OnboardingScreen());
      case AuthScreen.routeName:
        return animTransitionRoute(const AuthScreen());
      default:
        print('No route found for: ${settings.name}');
        return null;
    }
  }
}

// Wrapper for HomeScreen with BlocProvider to avoid unnecessary recreation
class HomeScreenWithBloc extends StatelessWidget {
  const HomeScreenWithBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: const HomeScreen(),
    );
  }
}

