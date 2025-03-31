import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voux/presentation/privacyPolicy/privacy_policy_screen.dart';
import 'presentation/agreement/agreement_screen.dart';
import 'presentation/settings/settings_screen.dart';
import 'presentation/splash/splash_screen.dart';
import 'presentation/success/success_screen.dart';
import 'presentation/upgrade/upgrade_screen.dart';
import 'presentation/onboarding/onboarding_screen.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/home/home_bloc.dart';
import 'presentation/anim/anim_transition_route.dart';
import 'presentation/auth/auth_screen.dart';
import 'theme/theme_util.dart';
import 'theme/theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ThemeMode initialTheme = await _loadThemeMode();
  themeNotifier.value = initialTheme; // Set the initial theme
  runApp(MyApp());
}

// Global theme notifier
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<ThemeMode> _loadThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  bool isDark = prefs.getBool(Constants.isDarkMode) ?? false;
  return isDark ? ThemeMode.dark : ThemeMode.light;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        TextTheme textTheme = createTextTheme(context);
        MaterialTheme theme = MaterialTheme(textTheme);

        return MaterialApp(
          title: Constants.appName,
          theme: theme.light(),
          darkTheme: theme.dark(),
          themeMode: themeMode, // Dynamic theme
          home: SplashScreen(),
          onGenerateRoute: (settings) => _onGenerateRoute(settings),
        );
      },
    );
  }

  PageRouteBuilder? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashScreen.routeName:
        return animTransitionRoute(const SplashScreen());
      case HomeScreen.routeName:
        return animTransitionRoute(const HomeScreenWithBloc());
      case OnboardingScreen.routeName:
        return animTransitionRoute(const OnboardingScreen());
      case AuthScreen.routeName:
        return animTransitionRoute(const AuthScreen());
      case PrivacyPolicyScreen.routeName:
        return animTransitionRoute(const PrivacyPolicyScreen());
      case AgreementScreen.routeName:
        return animTransitionRoute(const AgreementScreen());
      case SettingsScreen.routeName:
        return animTransitionRoute(SettingsScreen());
      case UpgradeScreen.routeName:
        return animTransitionRoute(UpgradeScreen());
      case SuccessScreen.routeName:
        return animTransitionRoute(SuccessScreen());
      default:
        return null;
    }
  }
}

class HomeScreenWithBloc extends StatelessWidget {
  const HomeScreenWithBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: HomeScreen(),
    );
  }
}
