import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../reusables/more_bottom_sheet.dart';
import '../../models/optional_analysis_result_model.dart';
import '../../utils/constants.dart';
import '../reusables/report_bottom_sheet.dart';
import '../reusables/stacked_avatar_badge.dart';
import '../../models/clothing_item_model.dart';
import '../../utils/extensions.dart';
import '../reusables/stacked_text_badge.dart';

class DetailScreen extends StatelessWidget {
  final String imagePath;
  final List<ClothingItemModel> clothingItems;
  final OptionalAnalysisResult optionalAnalysisResult;

  const DetailScreen({super.key, required this.imagePath, required this.clothingItems, required this.optionalAnalysisResult});

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
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium),
                                      color: Theme.of(context).colorScheme.secondaryContainer,
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.child_care_rounded, color: Theme.of(context).colorScheme.onSecondaryContainer),
                                      onPressed: () {
                                        // Your action
                                      },
                                    ),
                                  ),
                                if (optionalAnalysisResult.gender != Constants.unknown)
                                  Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium),
                                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                                      ),
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
                        child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium),
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            child: IconButton(
                                padding: EdgeInsets.zero,
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
                                StackedTextBadge(profileImage: "assets/images/woman_avatar.png", badgeImage: "assets/images/hanger.png", title: "+${clothingItems.length}"),
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
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: clothingItems.length,
                                itemBuilder: (context, index) {
                                  final item = clothingItems[index];
                                  return buildItemWidget(context, item);
                                },
                              )
                            ],
                          )
                        ],
                      )
                  ),
                  SizedBox(height: 16)
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

  Widget buildItemWidget(BuildContext context, ClothingItemModel item) {
    final details = item.toDetailString(optionalAnalysisResult);
    print(details);

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
                    onPressed: () async {
                      final googleResults = await fetchGoogleImages(details);
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) {
                          return MoreBottomSheet(
                              imagePath: imagePath,
                              googleResults: googleResults,
                              clothingItemModel: item,
                              optionalAnalysisResult: optionalAnalysisResult
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.more_vert_rounded, color: Theme.of(context).colorScheme.onSurface),
                  )
                ],
              ),
              SizedBox(height: 8),
              Padding(
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 8,
                    bottom: 8,
                  ),
                  child: Column(
                    children: [
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
                            return results.isNotEmpty ? Container(
                              height: 96,
                              clipBehavior: Constants.clipBehaviour,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium),
                              ),
                              child: PageView.builder(
                                controller: PageController(),
                                itemCount: results.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  final result = results[index];
                                  return GestureDetector(
                                    onTap: () => _goToProductWebPageInBrowser(context, result['productUrl']!),
                                    child: Stack(
                                      children: [
                                        Image.network(
                                          result['imageUrl']!,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(Constants.cornerRadiusMedium),
                                                  bottomRight: Radius.circular(Constants.cornerRadiusMedium),
                                                ),
                                                color: Theme.of(context).colorScheme.surface,
                                              ),
                                              child: IconButton(
                                                  onPressed: () => _showFullScreenImage(context, result['imageUrl']!),
                                                  padding: EdgeInsets.all(12),
                                                  icon: Icon(Icons.open_in_full_rounded, color: Theme.of(context).colorScheme.primary)
                                              ),
                                            )
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ) : SizedBox.shrink();
                          } else {
                            print('No images found');
                            return SizedBox.shrink();
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          SelectableText(
                                              details,
                                              style: Theme.of(context).textTheme.titleLarge
                                          ),
                                          SizedBox(height: 16),
                                          GestureDetector(
                                            onTap: () => copyToClipboard(context, item.colorHexCode),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: item.colorHexCode.toColor(),
                                                    border: Border.all(
                                                      color: item.colorHexCode.toColor().isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(25),
                                                      width: Constants.borderWidth,
                                                    ),
                                                    borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium)
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 2
                                                ),
                                                child: Text(
                                                  item.color,
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: item.colorHexCode.toColor().isDark ? Colors.white : Colors.black,
                                                  ),
                                                )
                                            )
                                          )
                                        ],
                                      )
                                  ),
                                  SizedBox(width: 8),
                                  Text(item.price.toFormattedPrice(), style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer))
                                ]
                            )
                        ),
                      )
                    ],
                  )
              )
            ],
          ),
        )
    );
  }

  Future<List<Map<String, String>>> fetchGoogleImages(String query) async {
    const String apiKey = Constants.cseApiKey;
    const String cx = Constants.cseId;
    const int numOfImgs = Constants.numOfImgsPlus;

    final Uri url = Uri.parse(
      'https://www.googleapis.com/customsearch/v1?q=$query&cx=$cx&searchType=image&num=$numOfImgs&key=$apiKey',
    );

    try {
      final response = await http.get(url);
      print("Google API Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] == null) return [];

        final List<Map<String, String>> results = [];

        for (var item in data['items']) {
          results.add({
            'imageUrl': item['link'] ?? '',
            'productUrl': item['image']['contextLink'] ?? '',
          });
        }

        return results;
      } else {
        print('Google Search API Error: ${response.body}');
        return []; // ← Don't throw, just return an empty list
      }
    } catch (e) {
      print('Exception in fetchGoogleImages: $e');
      return []; // ← Same here
    }
  }

  Future<void> _goToProductWebPageInBrowser(BuildContext context, String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      context.showCustomSnackBar(Constants.error, "Could not launch $url");
      throw Exception('Could not launch $url');
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.all(24),
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    context.showCustomSnackBar(Constants.success, "Copied to clipboard");
  }
}
