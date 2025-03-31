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
                            onPressed: () => _showLangPicker(context),
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
  void _showLangPicker(BuildContext context) {
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
