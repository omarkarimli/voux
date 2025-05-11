import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'di/locator.dart';
import 'theme/theme_util.dart';
import 'theme/theme.dart';
import 'utils/constants.dart';
import 'presentation/auth/auth_view_model.dart';
import 'presentation/wishlist/wishlist_view_model.dart';
import 'presentation/detail/detail_view_model.dart';
import 'presentation/home/home_view_model.dart';
import 'presentation/wishlist/wishlist_screen.dart';
import 'presentation/settings/settings_screen.dart';
import 'presentation/splash/splash_screen.dart';
import 'presentation/success/success_screen.dart';
import 'presentation/upgrade/upgrade_screen.dart';
import 'presentation/onboarding/onboarding_screen.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/anim/anim_transition_route.dart';
import 'presentation/auth/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup DI before using locator
  await setupLocator();

  await EasyLocalization.ensureInitialized();

  final ThemeMode initialTheme = loadThemeMode();
  themeNotifier.value = initialTheme; // Set the initial theme

  runApp(
    EasyLocalization(
      supportedLocales: Constants.listLocales,
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

// Global theme notifier
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

// Load theme preference from SharedPreferences
ThemeMode loadThemeMode() {
  final prefs = locator<SharedPreferences>();
  final String? themePref = prefs.getString(Constants.theme);

  if (themePref == null) {
    prefs.setString(Constants.theme, Constants.themeSystem);

    // No preference saved — follow system
    return ThemeMode.system;
  } else {
    if (themePref == Constants.themeLight) {
      return ThemeMode.light;
    } else if (themePref == Constants.themeDark) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }
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

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => locator<HomeViewModel>()),
            ChangeNotifierProvider(create: (_) => locator<DetailViewModel>()),
            ChangeNotifierProvider(create: (_) => locator<WishlistViewModel>()),
            ChangeNotifierProvider(create: (_) => locator<AuthViewModel>()),
            // Add more providers here if necessary
          ],
          child: MaterialApp(
            title: Constants.appName,
            theme: theme.light(),
            darkTheme: theme.dark(),
            themeMode: themeMode,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: SplashScreen(),
            onGenerateRoute: (settings) => onGenerateRoute(settings),
          )
        );
      },
    );
  }

  PageRouteBuilder? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashScreen.routeName:
        return animTransitionRoute(const SplashScreen());
      case HomeScreen.routeName:
        return animTransitionRoute(HomeScreen());
      case OnboardingScreen.routeName:
        return animTransitionRoute(const OnboardingScreen());
      case AuthScreen.routeName:
        return animTransitionRoute(const AuthScreen());
      case SettingsScreen.routeName:
        return animTransitionRoute(SettingsScreen());
      case UpgradeScreen.routeName:
        return animTransitionRoute(UpgradeScreen());
      case SuccessScreen.routeName:
        return animTransitionRoute(SuccessScreen());
      case WishlistScreen.routeName:
        return animTransitionRoute(WishlistScreen());
      default:
        return null;
    }
  }
}
