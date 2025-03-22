import 'package:flutter/material.dart';

class StackedAvatarBadge extends StatelessWidget {
  final String profileImage;
  final String badgeImage;
  final double badgeSize;

  const StackedAvatarBadge({
    super.key,
    required this.profileImage,
    required this.badgeImage,
    required this.badgeSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 32),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 24, // Circle size
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: ClipOval(
                  child: Image.asset(
                    profileImage,
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 3,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              radius: 24,
              child: ClipOval(
                child: Image.asset(
                  badgeImage,
                  width: badgeSize,
                  height: badgeSize,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          )
        ],
      );
  }
}
