import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voux/models/clothing_item_model.dart';
import 'package:voux/utils/extensions.dart';
import 'dart:io';
import '../../utils/constants.dart';
import 'stacked_avatar_badge.dart';

class DetailScreen extends StatelessWidget {
  final String imagePath;
  final List<ClothingItemModel> clothingItems;
  final String gender;
  final bool isChildOrNot;

  const DetailScreen({super.key, required this.imagePath, required this.clothingItems, required this.gender, required this.isChildOrNot});

  static const routeName = '/${Constants.detail}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: MediaQuery.of(context).padding.top + 16, bottom: 64),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display Image
                    Stack(
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.file(
                              File(imagePath),
                              width: MediaQuery.of(context).size.width,
                              height: 332,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset('assets/placeholder.png', width: 128, height: 128, fit: BoxFit.cover);
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 24,
                          right: 24,
                          child: Row(
                            spacing: 8,
                            children: [
                              if (isChildOrNot)
                                CircleAvatar(
                                radius: 24,
                                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                child: IconButton(
                                  icon: Icon(Icons.child_care_rounded, color: Theme.of(context).colorScheme.onSecondaryContainer),
                                  onPressed: () {
                                    // Your action
                                  },
                                ),
                              ),
                              if (gender != Constants.unknown)
                                CircleAvatar(
                                radius: 24,
                                backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                                child: Icon(
                                    gender == Constants.male ? Icons.male_rounded : Icons.female_rounded,
                                    color: Theme.of(context).colorScheme.secondaryContainer
                                )
                              ),
                            ]
                          )
                        ),
                      ],
                    ),
                    SizedBox(height: 22),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                              children: [
                                StackedAvatarBadge(profileImage: "assets/images/woman_avatar.png", badgeImage: "assets/images/hanger.png", badgeSize: 32),
                                SizedBox(width: 16),
                                Container(
                                  width: 1,
                                  height: 54,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                SizedBox(width: 16),
                                Text("${clothingItems.length} items", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                              ]
                          ),
                          ElevatedButton(
                              onPressed: (){},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                              ),
                              child: Text("Report", style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onErrorContainer))
                          )
                        ]
                    ),
                    SizedBox(height: 22),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Existing UI elements
                        SizedBox(height: 22),
                        ...clothingItems.map((item) => _buildItemWidget(context, item)),
                      ],
                    )
                  ],
                ),
              )
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 32,
            left: 32,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemWidget(BuildContext context, ClothingItemModel item) {
    String details = "";
    if (item.name != Constants.unknown) {
      details += " ${item.name}";
    }
    if (item.color != Constants.unknown) {
      details += " ${item.color}";
    }
    if (item.type != Constants.unknown) {
      details += " ${item.type}";
    }
    if (item.material != Constants.unknown) {
      details += " ${item.material}";
    }
    if (item.brand != Constants.unknown) {
      details += " ${item.brand}";
    }
    if (item.model != Constants.unknown) {
      details += " ${item.model}";
    }

    Uri searchUrl = Uri.parse("https://www.google.com/search?q=${Uri.encodeComponent(details)}");

    // Return a single card for each item containing all the details
    return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StackedAvatarBadge(profileImage: "assets/images/woman_avatar.png", badgeImage: "assets/images/stack.png", badgeSize: 24),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        child: IconButton(
                          onPressed: () async {
                            if (await canLaunchUrl(searchUrl)) {
                              await launchUrl(searchUrl, mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: Icon(Icons.arrow_outward_rounded, color: Theme.of(context).colorScheme.onSurface),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 22),
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.size != Constants.unknown)
                          Text(item.size, style: Theme.of(context).textTheme.bodyLarge),
                        Text(details.chunkText(16).capitalizeFirst(), style: Theme.of(context).textTheme.titleLarge),
                      ],
                    )
                  )
                ],
              ),
            )
          ],
        )
    );
  }
}
