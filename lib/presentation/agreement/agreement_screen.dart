import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AgreementScreen extends StatelessWidget {
  const AgreementScreen({super.key});

  static const routeName = '/${Constants.agreement}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: MediaQuery.of(context).padding.top + 72,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agreement',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  Constants.agreementText,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 48),
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
      )
    );
  }
}
