import 'package:flutter/material.dart';
import 'package:voux/presentation/reusables/stacked_avatar_badge.dart';

import '../../utils/constants.dart';

class StackedBadgedText extends StatelessWidget {
  final String badgeImage;
  final double badgePadding;
  final String text;

  const StackedBadgedText({
    super.key,
    required this.badgeImage,
    this.badgePadding = 6,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      clipBehavior: Constants.clipBehaviour,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.cornerRadiusLarge),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withAlpha(50),
          width: 2
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          right: 20,
          left: 8,
          top: 8,
          bottom: 8,
        ),
        child: Row(
          children: [
            StackedAvatarBadge(profileImage: "assets/images/woman_avatar.png", badgeImage: "assets/images/hanger.png", badgePadding: badgePadding),
            SizedBox(width: 14),
            Text(text, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer))
          ],
        )
      ),
    );
  }
}
