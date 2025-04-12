import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../agreement/agreement_screen.dart';
import '../auth/auth_screen.dart';
import '../privacyPolicy/privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const routeName = '/${Constants.settings}';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode? themeMode;

  bool? isDarkModeEnabled;
  bool? isNotificationEnabled;

  @override
  void initState() {
    super.initState();

    loadSettings();
  }

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkModeEnabled = prefs.getBool(Constants.isDarkMode) ?? false;
      isNotificationEnabled = prefs.getBool(Constants.canNoti) ?? false;

      themeMode = isDarkModeEnabled! ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isDarkModeEnabled == null || isNotificationEnabled == null) {
      return Center(
          child: CupertinoActivityIndicator(
              radius: 20.0,
              color: Theme.of(context).colorScheme.primary
          )
      );
    }

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
                            CupertinoSwitch(
                              value: isNotificationEnabled!,
                              activeTrackColor: CupertinoColors.activeBlue,
                              onChanged: (bool? value) {
                                setState(() {
                                  isNotificationEnabled = value ?? false;
                                });
                                saveNotificationPreference(isNotificationEnabled!);
                              },
                            )
                          ],
                        ),
                        Divider(color: Theme.of(context).colorScheme.outline.withAlpha(50)),

                        // Dark Mode
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Dark mode', style: Theme.of(context).textTheme.bodyLarge),
                            CupertinoSwitch(
                              value: isDarkModeEnabled!,
                              activeTrackColor: CupertinoColors.activeBlue,
                              onChanged: (bool? value) {
                                setState(() {
                                  isDarkModeEnabled = value ?? false;
                                });

                                // Save dark mode preference
                                saveDarkModePreference(isDarkModeEnabled!);

                                // Update global theme mode
                                themeNotifier.value = isDarkModeEnabled! ? ThemeMode.dark : ThemeMode.light;
                              },
                            )
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
          ),

          // Sign out
          Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => showConfirmationDialog(),
                child: Card(
                    elevation: 3,
                    clipBehavior: Constants.clipBehaviour,
                    color: Theme.of(context).colorScheme.errorContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium),
                    ),
                    child: Padding(
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 8,
                          top: 4,
                          bottom: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sign out', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onErrorContainer)),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.exit_to_app_rounded, size: 24, color: Theme.of(context).colorScheme.onErrorContainer),
                            ),
                          ],
                        )
                    )
                )
              )
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

  // Save notification setting to preferences
  Future<void> saveNotificationPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.canNoti, value);
  }

  // Save dark mode preference to preferences
  Future<void> saveDarkModePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.isDarkMode, value);
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushNamedAndRemoveUntil(context, AuthScreen.routeName, (route) => false);
  }

  void showConfirmationDialog() {
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
}
