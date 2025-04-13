import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../di/locator.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../agreement/agreement_screen.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../privacyPolicy/privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const routeName = '/${Constants.settings}';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode? themeMode;

  void resetSettings() async {
    await Future.wait([
      locator<SharedPreferences>().setString(Constants.theme, Constants.themeSystem),
      locator<SharedPreferences>().setString(Constants.notification, Constants.notificationSystem),
    ]);

    themeNotifier.value = ThemeMode.system;

    Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: MediaQuery.of(context).padding.top + 72,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: ListView(
                        children: [
                          // Notification
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Notification', style: Theme.of(context).textTheme.bodyLarge),
                              IconButton(
                                onPressed: () => showNotificationPicker(context),
                                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                              ),
                            ],
                          ),
                          Divider(color: Theme.of(context).colorScheme.outline.withAlpha(50)),

                          // Theme
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Theme', style: Theme.of(context).textTheme.bodyLarge),
                              IconButton(
                                onPressed: () => showThemePicker(context),
                                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                              ),
                            ],
                          ),
                          Divider(color: Theme.of(context).colorScheme.outline.withAlpha(50)),

                          // Language
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Language', style: Theme.of(context).textTheme.bodyLarge),
                              IconButton(
                                onPressed: () => showLangPicker(context),
                                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                              ),
                            ],
                          ),
                          Divider(color: Theme.of(context).colorScheme.outline.withAlpha(50)),

                          // Account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Account', style: Theme.of(context).textTheme.bodyLarge),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                              ),
                            ],
                          ),
                          Divider(color: Theme.of(context).colorScheme.outline.withAlpha(50)),

                          // Privacy Policy
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Privacy Policy', style: Theme.of(context).textTheme.bodyLarge),
                              IconButton(
                                onPressed: () => Navigator.pushNamed(context, PrivacyPolicyScreen.routeName),
                                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                              ),
                            ],
                          ),
                          Divider(color: Theme.of(context).colorScheme.outline.withAlpha(50)),

                          // Agreement
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Agreement', style: Theme.of(context).textTheme.bodyLarge),
                              IconButton(
                                onPressed: () => Navigator.pushNamed(context, AgreementScreen.routeName),
                                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                              ),
                            ],
                          ),
                          Divider(color: Theme.of(context).colorScheme.outline.withAlpha(50)),

                          // About app
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('About app', style: Theme.of(context).textTheme.bodyLarge),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                              ),
                            ],
                          ),
                          Divider(color: Theme.of(context).colorScheme.outline.withAlpha(50)),

                          // Sign out
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Reset Settings', style: Theme.of(context).textTheme.bodyLarge),
                              IconButton(
                                onPressed: () => showResetSettingsConfirmationDialog(),
                                icon: const Icon(Icons.restart_alt_rounded, size: 20),
                              ),
                            ],
                          ),
                          Divider(color: Theme.of(context).colorScheme.outline.withAlpha(50)),

                          // Sign out
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Sign out', style: Theme.of(context).textTheme.bodyLarge),
                              IconButton(
                                onPressed: () => showSignOutConfirmationDialog(),
                                icon: const Icon(Icons.exit_to_app_rounded, size: 20),
                              ),
                            ],
                          )
                        ],
                      )
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface)
            ),
          )
        ],
      ),
    );
  }

  // Show language selection sheet
  void showLangPicker(BuildContext context) {
    final List<String> languages = ['English', 'Azerbaijani', 'Spanish', 'French'];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        int selectedIndex = 0;

        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 96,
                child: CupertinoPicker(
                  itemExtent: 40.0,
                  scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                  onSelectedItemChanged: (int index) {
                    selectedIndex = index;
                  },
                  children: languages.map((lang) {
                    return Center(child: Text(lang, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.normal)));
                  }).toList(),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text("Select", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.surface)),
              ),
            ],
          ),
        );
      },
    );
  }

  // Show theme selection sheet
  void showThemePicker(BuildContext context) {
    final List<String> list = [Constants.themeSystem, Constants.themeLight, Constants.themeDark];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        String selectedValue = locator<SharedPreferences>().getString(Constants.theme) ?? Constants.themeSystem;
        int initialIndex = list.indexOf(selectedValue);
        int selectedIndex = initialIndex;

        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 96,
                child: CupertinoPicker(
                  itemExtent: 40.0,
                  scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                  onSelectedItemChanged: (int index) {
                    selectedIndex = index;
                  },
                  children: list.map((lang) {
                    return Center(child: Text(lang, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.normal)));
                  }).toList(),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (selectedIndex != initialIndex) selectTheme(list[selectedIndex]);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text("Select", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.surface)),
              ),
            ],
          ),
        );
      },
    );
  }

  // Show notification selection sheet
  void showNotificationPicker(BuildContext context) {
    final List<String> list = [Constants.notificationSystem, Constants.notificationOn, Constants.notificationOff];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        String selectedValue = locator<SharedPreferences>().getString(Constants.notification) ?? Constants.notificationSystem;
        int initialIndex = list.indexOf(selectedValue);
        int selectedIndex = initialIndex;

        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 96,
                child: CupertinoPicker(
                  itemExtent: 40.0,
                  scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                  onSelectedItemChanged: (int index) {
                    selectedIndex = index;
                  },
                  children: list.map((lang) {
                    return Center(child: Text(lang, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.normal)));
                  }).toList(),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (selectedIndex != initialIndex) selectNotification(list[selectedIndex]);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text("Select", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.surface)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> selectNotification(String value) async {
    await locator<SharedPreferences>().setString(Constants.notification, value);

    Navigator.pop(context);
  }

  Future<void> selectTheme(String value) async {
    await locator<SharedPreferences>().setString(Constants.theme, value);

    if (value == Constants.themeSystem) {
      themeNotifier.value = ThemeMode.system;
    } else if (value == Constants.themeLight) {
      themeNotifier.value = ThemeMode.light;
    } else {
      themeNotifier.value = ThemeMode.dark;
    }

    Navigator.pop(context);
  }

  Future<void> signOut() async {
    await Future.wait([
      locator<FirebaseAuth>().signOut(),
      locator<SharedPreferences>().clear(),
    ]);

    // Update global theme mode
    themeNotifier.value = ThemeMode.system;

    Navigator.pushNamedAndRemoveUntil(context, OnboardingScreen.routeName, (route) => false);
  }

  void showSignOutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Sign out", style: Theme.of(context).textTheme.titleLarge),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => signOut(),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void showResetSettingsConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Reset Settings", style: Theme.of(context).textTheme.titleLarge),
          content: Text("Are you sure you want to reset settings?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => resetSettings(),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
