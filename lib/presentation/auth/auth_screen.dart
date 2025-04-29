// declare JAVA_HOME in System Enviroument Variables
// C:\Program Files\Android\Android Studio\jbr
// cd C:\Users\Omar\Documents\FlutterProjects\Voux\android
// gradlew signingReport
// C:\Users\user\.android\debug.keystore

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voux/presentation/home/home_screen.dart';
import 'package:voux/utils/extensions.dart';
import '../../utils/constants.dart';
import 'auth_view_model.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/${Constants.auth}';
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthViewModel vm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    vm = Provider.of<AuthViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        if (vm.navigateToHome == true) {
          // Delay navigation to the next frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            vm.setNavigateToHomeScreen(false);

            context.showCustomSnackBar(Constants.success, "Signed as ${vm.auth.currentUser?.displayName}");

            // Navigate to HomeScreen
            Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
          });
        }

        if (vm.errorMessage != null) {
          final error = vm.errorMessage!;
          context.showCustomSnackBar(Constants.error, "Error: $error");
          Future.microtask(() => vm.clearError());
        }

        return Scaffold(
          body: AbsorbPointer(
            absorbing: vm.isLoading,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/bg.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24),
                      child: FittedBox(
                        child: Text(
                          Constants.appName,
                          style: TextStyle(
                            letterSpacing: 8,
                            fontFamily: "Aboreto",
                            fontSize: 112,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ),
                    )
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).padding.bottom + 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            await vm.signInWithGoogle();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.onSurface,
                              padding: EdgeInsets.symmetric(vertical: 12.0)
                          ),
                          icon: Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Image.asset(
                              'assets/images/google.png',
                              width: 18,
                              height: 18,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                          label: Text(
                            "Continue with Google",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                          iconAlignment: IconAlignment.start,
                        ),
                        SizedBox(height: 12.0),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await vm.signInWithApple();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                          ),
                          icon: Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Image.asset(
                              'assets/images/apple.png',
                              width: 18,
                              height: 18,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          label: Text(
                            "Continue with Apple",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          iconAlignment: IconAlignment.start,
                        ),
                      ],
                    ),
                  ),
                ),
                if (vm.isLoading)
                  Center(
                    child: Card(
                        color: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium)),
                        clipBehavior: Constants.clipBehaviour,
                        elevation: 3,
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: CupertinoActivityIndicator(
                              radius: 20.0,
                              color: Theme.of(context).colorScheme.primary,
                            )
                        )
                    ),
                  ),
              ],
            )
          ),
        );
      },
    );
  }
}
