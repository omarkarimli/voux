import 'package:flutter/material.dart';

class DenemeScreen extends StatefulWidget {

  const DenemeScreen({super.key});

  @override
  State<DenemeScreen> createState() => _DenemeScreenState();
}

class _DenemeScreenState extends State<DenemeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Stack(
          children: [
            Column(
              children: [
                TextField(
                  maxLength: 512,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "Ask Voux",
                    border: InputBorder.none,
                  )
                )
              ],
            )
          ],
        )
    );
  }
}
