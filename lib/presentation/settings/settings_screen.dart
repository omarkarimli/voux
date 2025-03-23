import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const routeName = '/${Constants.settings}';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode? themeMode;

  bool? _isDarkModeEnabled;
  bool? _isNotificationEnabled;

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkModeEnabled = prefs.getBool(Constants.isDarkMode) ?? false;
      _isNotificationEnabled = prefs.getBool(Constants.canNoti) ?? false;

      themeMode = _isDarkModeEnabled! ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDarkModeEnabled == null || _isNotificationEnabled == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
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
                  child: ListView(
                    children: [
                      // Notification
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Notification', style: Theme.of(context).textTheme.bodyLarge),
                          CupertinoSwitch(
                            value: _isNotificationEnabled!,
                            activeTrackColor: CupertinoColors.activeBlue,
                            onChanged: (bool? value) {
                              setState(() {
                                _isNotificationEnabled = value ?? false;
                              });
                              _saveNotificationPreference(_isNotificationEnabled!);
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
                            value: _isDarkModeEnabled!,
                            activeTrackColor: CupertinoColors.activeBlue,
                            onChanged: (bool? value) {
                              setState(() {
                                _isDarkModeEnabled = value ?? false;
                              });

                              // Save dark mode preference
                              _saveDarkModePreference(_isDarkModeEnabled!);

                              // Update global theme mode
                              themeNotifier.value = _isDarkModeEnabled! ? ThemeMode.dark : ThemeMode.light;
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
                            onPressed: () => _showLangSheet(context),
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
                            onPressed: () {},
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
  void _showLangSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CountryFlag.fromLanguageCode(
                  'en',
                  width: 24,
                  height: 18,
                ),
                title: const Text('English'),
                trailing: CupertinoCheckbox(
                  checkColor: Theme.of(context).colorScheme.surface,
                  value: true,
                  onChanged: (bool? value) {},
                ),
                onTap: () {},
              ),
              const Divider(height: 1, thickness: 1),
              ListTile(
                leading: CountryFlag.fromLanguageCode(
                  'az',
                  width: 24,
                  height: 18,
                ),
                title: const Text('Azerbaijani'),
                trailing: CupertinoCheckbox(
                  checkColor: Theme.of(context).colorScheme.surface,
                  value: false,
                  onChanged: (bool? value) {},
                ),
                onTap: () {},
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Save notification setting to preferences
  Future<void> _saveNotificationPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.canNoti, value);
  }

  // Save dark mode preference to preferences
  Future<void> _saveDarkModePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.isDarkMode, value);
  }
}
