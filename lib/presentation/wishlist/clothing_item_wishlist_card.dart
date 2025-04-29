import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../reusables/stacked_avatar_badge.dart';
import '../reusables/more_bottom_sheet.dart';
import '../../models/optional_analysis_result_model.dart';
import '../../models/clothing_item_floor_model.dart';
import '../../utils/extensions.dart';
import '../../utils/constants.dart';
import 'wishlist_view_model.dart';

class ClothingItemWishlistCard extends StatefulWidget {
  final WishlistViewModel vm;
  final String imagePath;
  final ClothingItemFloorModel item;
  final OptionalAnalysisResult optionalAnalysisResult;

  const ClothingItemWishlistCard({
    super.key,
    required this.vm,
    required this.optionalAnalysisResult,
    required this.item,
    required this.imagePath,
  });

  @override
  State<ClothingItemWishlistCard> createState() => _ClothingItemWishlistCardState();
}

class _ClothingItemWishlistCardState extends State<ClothingItemWishlistCard> {
  @override
  void initState() {
    super.initState();

    if (widget.item.clothingItemModel.sellerSources.isNotEmpty) {
      widget.item.clothingItemModel.setSelectedSource(widget.item.clothingItemModel.sellerSources[0].name);
    }
  }

  // Select Source
  Future<void> selectSource(String value) async {
    setState(() {
      widget.item.clothingItemModel.setSelectedSource(value);
    });

    Navigator.pop(context);
  }

  // Show source selection sheet
  void showSourcePicker(BuildContext context) {
    final List<String> list = ["Amazon", "Ebay", "Alibaba"];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        String selectedValue = widget.item.clothingItemModel.selectedSource!;
        int initialIndex = list.indexOf(selectedValue);
        int selectedIndex = initialIndex;

        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 96,
                child: CupertinoPicker(
                  itemExtent: 40.0,
                  scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                  onSelectedItemChanged: (int index) {
                    selectedIndex = index;
                  },
                  children: list.map((lang) {
                    return Center(child: Text(lang, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.normal)));
                  }).toList(),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (selectedIndex != initialIndex) selectSource(list[selectedIndex]);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text("Select", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.surface)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> goToProductWebPageInBrowser(BuildContext context, String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      context.showCustomSnackBar(Constants.error, "Could not launch $url");
      throw Exception('Could not launch $url');
    }
  }

  void showFullScreenImage(BuildContext context, String imagePath, bool isWebImg) {
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
                child: isWebImg ? Image.network(imagePath, fit: BoxFit.contain) : Image.file(File(imagePath), fit: BoxFit.contain)
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 18,
              right: 14,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    context.showCustomSnackBar(Constants.success, "Copied to clipboard");
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final details = item.clothingItemModel.toDetailString(widget.optionalAnalysisResult);
    print(details);

    return GestureDetector(
        onLongPress: () async {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) {
              return MoreBottomSheet(
                  imagePath: widget.imagePath,
                  googleResults: item.googleResults,
                  clothingItemModel: item.clothingItemModel,
                  optionalAnalysisResult: widget.optionalAnalysisResult
              );
            },
          ).then((_) {
            widget.vm.loadWishlist(); // Refresh wishlist after closing bottom sheet
          });
        },
        child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constants.cornerRadiusLarge)),
            clipBehavior: Constants.clipBehaviour,
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StackedAvatarBadge(profileImage: "assets/images/woman_1.png", badgeImage: "assets/images/stack.png", badgePadding: 10),
                      IconButton(
                          onPressed: () async {
                            showModalBottomSheet(
                              context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (context) {
                                return MoreBottomSheet(
                                    imagePath: widget.imagePath,
                                    googleResults: item.googleResults,
                                    clothingItemModel: item.clothingItemModel,
                                    optionalAnalysisResult: widget.optionalAnalysisResult
                                );
                              },
                            ).then((_) {
                              widget.vm.loadWishlist(); // Refresh wishlist after closing bottom sheet
                            });
                          },
                          icon: Image.asset(
                            "assets/images/menu.png",
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 24,
                            height: 24,
                          )
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
                          item.googleResults.isNotEmpty
                            ? Container(
                            height: 96,
                            clipBehavior: Constants.clipBehaviour,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium),
                            ),
                            child: PageView.builder(
                              controller: PageController(),
                              itemCount: item.googleResults.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                final result = item.googleResults[index];
                                return GestureDetector(
                                  onDoubleTap: () => goToProductWebPageInBrowser(context, result['productUrl']!),
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
                                                onPressed: () => showFullScreenImage(context, result['imageUrl']!, true),
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
                          )
                            : Container(
                            height: 96,
                            clipBehavior: Constants.clipBehaviour,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium),
                            ),
                            child: Stack(
                              children: [
                                Image.file(
                                  File(widget.imagePath),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset('assets/placeholder.png', width: 128, height: 128, fit: BoxFit.cover);
                                  },
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
                                          onPressed: () => showFullScreenImage(context, item.imagePath, false),
                                          padding: EdgeInsets.all(12),
                                          icon: Icon(Icons.open_in_full_rounded, color: Theme.of(context).colorScheme.primary)
                                      ),
                                    )
                                )
                              ],
                            )
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
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                      onTap: () => copyToClipboard(context, item.clothingItemModel.colorHexCode),
                                                      child: Container(
                                                          clipBehavior: Constants.clipBehaviour,
                                                          decoration: BoxDecoration(
                                                              color: item.clothingItemModel.colorHexCode.toColor(),
                                                              border: Border.all(
                                                                color: item.clothingItemModel.colorHexCode.toColor().isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(25),
                                                                width: Constants.borderWidthLarge,
                                                              ),
                                                              borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium)
                                                          ),
                                                          padding: EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 2
                                                          ),
                                                          child: Text(
                                                            item.clothingItemModel.color,
                                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                              color: item.clothingItemModel.colorHexCode.toColor().isDark ? Colors.white : Colors.black,
                                                            ),
                                                          )
                                                      )
                                                  ),
                                                  SizedBox(width: 8),
                                                  if (item.clothingItemModel.selectedSource != null && item.clothingItemModel.selectedSource!.isNotEmpty)
                                                    GestureDetector(
                                                        onTap: () => showSourcePicker(context),
                                                        child: Container(
                                                            clipBehavior: Constants.clipBehaviour,
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                  color: Theme.of(context).colorScheme.onSecondaryContainer.withAlpha(25),
                                                                  width: Constants.borderWidthMedium,
                                                                ),
                                                                borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium)
                                                            ),
                                                            padding: EdgeInsets.only(
                                                              left: 12,
                                                              right: 6,
                                                              top: 4,
                                                              bottom: 4,
                                                            ),
                                                            child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text(item.clothingItemModel.selectedSource!.capitalizeFirst(), style: Theme.of(context).textTheme.bodySmall),
                                                                  SizedBox(width: 4),
                                                                  Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.onSecondaryContainer, size: 16)
                                                                ]
                                                            )
                                                        )
                                                    )
                                                ],
                                              )
                                            ],
                                          )
                                      ),
                                      SizedBox(width: 8),
                                      if (item.clothingItemModel.selectedSource != null && item.clothingItemModel.selectedSource!.isNotEmpty)
                                        Text(
                                            item.clothingItemModel.selectedSourcePrice(),
                                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer)
                                        )
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
        )
    );
  }
}
