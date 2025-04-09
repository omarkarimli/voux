import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../reusables/more_bottom_sheet.dart';
import '../../models/optional_analysis_result_model.dart';
import '../../utils/constants.dart';
import '../reusables/report_bottom_sheet.dart';
import '../reusables/stacked_avatar_badge.dart';
import '../../models/clothing_item_model.dart';
import '../../utils/extensions.dart';
import '../reusables/stacked_badged_text.dart';

class DetailScreen extends StatelessWidget {
  final String imagePath;
  final List<ClothingItemModel> clothingItems;
  final OptionalAnalysisResult optionalAnalysisResult;

  DetailScreen({super.key, required this.imagePath, required this.clothingItems, required this.optionalAnalysisResult});

  static const routeName = '/${Constants.detail}';

  double calculateTotalPrice() {
    return clothingItems.fold(0.0, (sum, item) => sum + (double.tryParse(item.price) ?? 0.0));
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = calculateTotalPrice();

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display Image
                  Stack(
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(Constants.cornerRadiusMedium),
                            bottomRight: Radius.circular(Constants.cornerRadiusMedium),
                          ),
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
                                if (optionalAnalysisResult.isChild)
                                  CircleAvatar(
                                    radius: Constants.cornerRadiusMedium,
                                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                    child: IconButton(
                                      icon: Icon(Icons.child_care_rounded, color: Theme.of(context).colorScheme.onSecondaryContainer),
                                      onPressed: () {
                                        // Your action
                                      },
                                    ),
                                  ),
                                if (optionalAnalysisResult.gender != Constants.unknown)
                                  CircleAvatar(
                                      radius: Constants.cornerRadiusMedium,
                                      backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                                      child: Icon(
                                          optionalAnalysisResult.gender == Constants.male ? Icons.male_rounded : Icons.female_rounded,
                                          color: Theme.of(context).colorScheme.secondaryContainer
                                      )
                                  ),
                              ]
                          )
                      ),
                      Positioned(
                          bottom: 24,
                          left: 24,
                          child: CircleAvatar(
                              radius: Constants.cornerRadiusMedium,
                              backgroundColor: Theme.of(context).colorScheme.errorContainer,
                              child: IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(Constants.cornerRadiusMedium)),
                                    ),
                                    builder: (context) {
                                      return ReportBottomSheet();
                                    },
                                  );
                                },
                                icon: Icon(
                                    Icons.error_outline_rounded,
                                    color: Theme.of(context).colorScheme.onErrorContainer
                                )
                              )
                          ),
                      )
                    ],
                  ),
                  SizedBox(height: 22),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StackedBadgedText(badgeImage: "assets/images/hanger.png", text: "${clothingItems.length}  🛍️"),
                              SizedBox(width: 16),
                              if (totalPrice > 0)
                                SelectableText(totalPrice.toStringAsFixed(2).toFormattedPrice(), style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer)),
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
                  ),
                  SizedBox(height: 72)
                ],
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
    if (item.size != Constants.unknown) {
      details += " ${item.size}";
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

    details = optionalAnalysisResult.gender + details;
    print(details);

    // Return a single card for each item containing all the details
    return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constants.cornerRadiusLarge)),
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StackedAvatarBadge(profileImage: "assets/images/woman_avatar.png", badgeImage: "assets/images/stack.png", badgePadding: 10),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) {
                          return MoreBottomSheet(details: details, imagePath: imagePath, price: item.price);
                        },
                      );
                    },
                    icon: Icon(Icons.more_vert_rounded, color: Theme.of(context).colorScheme.onSurface),
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
                    return Container(
                      height: 96,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 6),
                      child: PageView.builder(
                        controller: PageController(),
                        itemCount: results.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final result = results[index];
                          return GestureDetector(
                            onTap: () => _goToProductWebPageInBrowser(context, result['productUrl']!),
                            child: Image.network(
                              result['imageUrl']!,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SelectableText(details.chunkText(16).capitalizeFirst(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.normal)),
                      SelectableText(item.price.toFormattedPrice(), style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer))
                    ],
                  )
              )
            ],
          ),
        )
    );
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
    const int numOfImgs = Constants.numOfImgsPlus;

    final Uri url = Uri.parse(
      'https://www.googleapis.com/customsearch/v1?q=$query&cx=$cx&searchType=image&num=$numOfImgs&key=$apiKey',
    );

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
