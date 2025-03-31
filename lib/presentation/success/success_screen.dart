import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../presentation/home/home_screen.dart';
import '../../utils/constants.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  static const routeName = '/${Constants.success}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
              alignment: Alignment.center,
              child: FittedBox(
                child: Lottie.asset(
                  'assets/animations/success.json',
                  width: 224,
                  height: 224,
                  fit: BoxFit.cover,
                  repeat: false
                ),
              )
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 36),
                child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.onSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Text("Continue", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.surface)),
                        )
                    )
                )
            ),
          ),
        ],
      ),
    );
  }
}
