import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../../utils/constants.dart';
import '../reusables/report_bottom_sheet.dart';
import '../reusables/stacked_avatar_badge.dart';
import '../../models/clothing_item_model.dart';
import '../../utils/extensions.dart';

class DetailScreen extends StatelessWidget {
  final String imagePath;
  final List<ClothingItemModel> clothingItems;
  final String gender;
  final bool isChildOrNot;

  const DetailScreen({super.key, required this.imagePath, required this.clothingItems, required this.gender, required this.isChildOrNot});

  static const routeName = '/${Constants.detail}';
  static const listImg = [
    "assets/images/d1.png",
    "assets/images/d2.png",
    "assets/images/d3.png",
    "assets/images/d4.png"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Abstract
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/abstract_1.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
          SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(left: 4, right: 4, top: MediaQuery.of(context).padding.top + 8, bottom: MediaQuery.of(context).padding.bottom + 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display Image
                    Stack(
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.file(
                              File(imagePath),
                              width: MediaQuery.of(context).size.width,
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
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
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                        ),
                                        builder: (context) {
                                          return ReportBottomSheet();
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.errorContainer,
                                    ),
                                    child: Text("Report", style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onErrorContainer))
                                )
                              ]
                          ),
                          SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Existing UI elements
                              SizedBox(height: 12),
                              ...clothingItems.map((item) => _buildItemWidget(context, item)),
                            ],
                          )
                        ],
                      )
                    )
                  ],
                ),
              )
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 18,
            left: 14,
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

    details = gender + details;
    print(details);

    // Return a single card for each item containing all the details
    return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        child: Stack(
          children: [
            Positioned(
                bottom: -32,
                right: -58,
                child: Image.asset(
                  listImg[clothingItems.indexOf(item) % listImg.length],
                  width: 192,
                )
            ),
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
                          onPressed: () => _searchInBrowser(context, details),
                          icon: Icon(Icons.arrow_outward_rounded, color: Theme.of(context).colorScheme.onSurface),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 8),
                  FutureBuilder<List<Map<String, String>>>(
                    future: fetchGoogleImages(details), // Fetch images with links
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: CupertinoActivityIndicator(
                                radius: 20.0,
                                color: Theme.of(context).colorScheme.primary
                            )
                        );
                      } else if (snapshot.hasError) {
                        print('Error: ${snapshot.error}');
                        return SizedBox.shrink();
                      } else if (snapshot.hasData) {
                        final results = snapshot.data!;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: results.map((result) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () => _goToProductWebPageInBrowser(context, result['productUrl']!),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      result['imageUrl']!,
                                      width: 128,
                                      height: 96,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      } else {
                        print('No images found');
                        return SizedBox.shrink();
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.size != Constants.unknown)
                            Text(item.size, style: Theme.of(context).textTheme.bodyLarge),
                          Text(details.chunkText(16).capitalizeFirst(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.normal)),
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

  Future<void> _searchInBrowser(BuildContext context, String query) async {
    // onPressed calls using this URL are not gated on a 'canLaunch' check
    // because the assumption is that every device can launch a web URL.
    final Uri url = Uri.https('www.google.com', '/search', {'q': query});

    print(url);

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      context.showCustomSnackBar(Constants.error, "Could not launch $url");
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _goToProductWebPageInBrowser(BuildContext context, String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      context.showCustomSnackBar(Constants.error, "Could not launch $url");
      throw Exception('Could not launch $url');
    }
  }

  Future<List<Map<String, String>>> fetchGoogleImages(String query) async {
    const String apiKey = Constants.cseApiKey;
    const String cx = Constants.cseId;

    final Uri url = Uri.parse(
        'https://www.googleapis.com/customsearch/v1?q=$query&cx=$cx&searchType=image&key=$apiKey');

    final response = await http.get(url);
    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Map<String, String>> results = [];

      for (var item in data['items']) {
        results.add({
          'imageUrl': item['link'], // Extract image URL
          'productUrl': item['image']['contextLink'], // Extract product page link
        });
      }

      return results;
    } else {
      throw Exception('Failed to load images');
    }
  }
}
