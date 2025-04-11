import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class StackedAvatarBadge extends StatelessWidget {
  final String profileImage;
  final String badgeImage;
  final double badgePadding;

  const StackedAvatarBadge({
    super.key,
    required this.profileImage,
    required this.badgeImage,
    this.badgePadding = 6
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.centerLeft,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 32),
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
