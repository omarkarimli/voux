import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class StackedTextBadge extends StatelessWidget {
  final String profileImage;
  final String badgeImage;
  final double badgePadding;
  final String title;

  const StackedTextBadge({
    super.key,
    required this.profileImage,
    required this.badgeImage,
    this.badgePadding = 6,
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 64),
          child: Container(
            width: 49,
            height: 49,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium),
                color: Theme.of(context).colorScheme.primary
            ),
            alignment: Alignment.center,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(left: 32),
          child: Container(
            width: 49,
            height: 49,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium),
                color: Theme.of(context).colorScheme.primaryContainer
            ),
            child: Image.asset(
              profileImage,
              fit: BoxFit.cover,
            ),
          ),
        ),

        Container(
          width: 56,
          height: 56,
          padding: EdgeInsets.all(badgePadding),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primaryContainer,
            border: Border.all(
              color: Theme.of(context).colorScheme.surface,
              width: 3,
            ),
          ),
          child: Image.asset(
            badgeImage,
            fit: BoxFit.cover,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}
