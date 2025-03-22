import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
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

  Future<bool> _initializeApp() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    return _getLoginState();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    TextTheme textTheme = createTextTheme(context, "Poppins", "Poppins");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      title: Constants.appName,
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      darkTheme: ThemeData.dark(),
      home: FutureBuilder<bool>(
        future: _initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? const HomeScreenWithBloc() : const OnboardingScreen();
        },
      ),
      onGenerateRoute: (settings) {
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
      },
    );
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

// Function to get login state from SharedPreferences
Future<bool> _getLoginState() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}
