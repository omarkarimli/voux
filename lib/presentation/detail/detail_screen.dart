import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../detail/detail_view_model.dart';
import '../home/home_screen.dart';
import '../reusables/more_bottom_sheet.dart';
import '../../models/optional_analysis_result_model.dart';
import '../../utils/constants.dart';
import '../reusables/report_bottom_sheet.dart';
import '../reusables/stacked_avatar_badge.dart';
import '../../models/clothing_item_model.dart';
import '../../utils/extensions.dart';
import '../reusables/stacked_text_badge.dart';

class DetailScreen extends StatefulWidget {
  final String imagePath;
  final List<ClothingItemModel> clothingItems;
  final OptionalAnalysisResult optionalAnalysisResult;

  const DetailScreen({super.key, required this.imagePath, required this.clothingItems, required this.optionalAnalysisResult});

  static const routeName = '/${Constants.detail}';

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {

  @override
  Widget build(BuildContext context) {
    final totalPrice = calculateTotalPrice();
    return Consumer<DetailViewModel>(
      builder: (context, vm, _) {
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
                                  File(widget.imagePath),
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
                                      if (widget.optionalAnalysisResult.isChild)
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
                                      if (widget.optionalAnalysisResult.gender != Constants.unknown)
                                        Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium),
                                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                                            ),
                                            child: Icon(
                                                widget.optionalAnalysisResult.gender == Constants.male ? Icons.male_rounded : Icons.female_rounded,
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
                                      StackedTextBadge(profileImage: "assets/images/woman_avatar.png", badgeImage: "assets/images/hanger.png", title: "+${widget.clothingItems.length}"),
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
                                      itemCount: widget.clothingItems.length,
                                      itemBuilder: (context, index) {
                                        final item = widget.clothingItems[index];
                                        return buildItemWidget(context, vm, item);
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
                      onPressed: () {
                        Future.microtask(() {
                          Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
                        });
                      },
                    ),
                  ),
                ),
              ],
            )
        );
      },
    );
  }

  Widget buildItemWidget(BuildContext context, DetailViewModel vm, ClothingItemModel item) {
    final details = item.toDetailString(widget.optionalAnalysisResult);
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
                      final googleResults = await vm.fetchGoogleImages(details);
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) {
                          return MoreBottomSheet(
                              imagePath: widget.imagePath,
                              googleResults: googleResults,
                              clothingItemModel: item,
                              optionalAnalysisResult: widget.optionalAnalysisResult
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
                        future: vm.fetchGoogleImages(details), // Fetch images with links
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

  Future<void> _goToProductWebPageInBrowser(BuildContext context, String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      context.showCustomSnackBar(Constants.error, "Could not launch $url");
      throw Exception('Could not launch $url');
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(90),
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Detect tap outside
            GestureDetector(
              onTap: () => Navigator.pop(context),
              behavior: HitTestBehavior.translucent,
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

            // Centered image with interaction
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    context.showCustomSnackBar(Constants.success, "Copied to clipboard");
  }

  double calculateTotalPrice() {
    return widget.clothingItems.fold(0.0, (sum, item) => sum + (double.tryParse(item.price) ?? 0.0));
  }
}
