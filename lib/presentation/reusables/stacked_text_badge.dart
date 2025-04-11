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
        Container(
          width: 56,
          height: 56,
          padding: EdgeInsets.all(badgePadding),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface,
            border: Border.all(
              color: Theme.of(context).colorScheme.surface,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium),
          ),
          child: Image.asset(
            badgeImage,
            fit: BoxFit.cover,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 42),
          child: Container(
            width: 56,
            height: 56,
            clipBehavior: Constants.clipBehaviour,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 3,
                )
            ),
            child: ClipOval(
              child: Image.asset(
                profileImage,
                fit: BoxFit.cover,
              )
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 74),
          child: Container(
            width: 56,
            height: 56,
            clipBehavior: Constants.clipBehaviour,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 3,
                ),
                color: Theme.of(context).colorScheme.secondaryContainer
            ),
            alignment: Alignment.center,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
            ),
          ),
        ),
      ],
    );
  }
}
