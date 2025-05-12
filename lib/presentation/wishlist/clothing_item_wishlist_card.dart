import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../di/locator.dart';
import '../../models/store_model.dart';
import '../reusables/stacked_avatar_badge.dart';
import '../reusables/more_bottom_sheet.dart';
import '../../models/optional_analysis_result_model.dart';
import '../../models/clothing_item_floor_model.dart';
import '../../utils/extensions.dart';
import '../../utils/constants.dart';
import 'wishlist_view_model.dart';

class ClothingItemWishlistCard extends StatefulWidget {
  final BuildContext parentContext;
  final WishlistViewModel vm;
  final bool isSelecting;
  final String imagePath;
  final ClothingItemFloorModel item;
  final OptionalAnalysisResult optionalAnalysisResult;

  const ClothingItemWishlistCard({
    super.key,
    required this.parentContext,
    required this.vm,
    required this.isSelecting,
    required this.optionalAnalysisResult,
    required this.item,
    required this.imagePath,
  });

  @override
  State<ClothingItemWishlistCard> createState() => _ClothingItemWishlistCardState();
}

class _ClothingItemWishlistCardState extends State<ClothingItemWishlistCard> {

  bool enableExperimentalFeatures = false;

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      print(widget.item.clothingItemModelBoth.clothingItemModel?.price);
    }

    enableExperimentalFeatures = locator<SharedPreferences>().getBool(Constants.enableExperimentalFeatures) ?? false;

    if (enableExperimentalFeatures) {
      final experimentalModel = widget.item.clothingItemModelBoth.clothingItemModelExperimental;
      if (experimentalModel != null && experimentalModel.stores.isNotEmpty) {
        experimentalModel.setSelectedStore(experimentalModel.stores[0].name);
      }
    }
  }

  Widget titleContainer(ClothingItemFloorModel item) {
    final details = enableExperimentalFeatures
        ? (item.clothingItemModelBoth.clothingItemModelExperimental?.toDetailString(widget.optionalAnalysisResult)
        ?? (item.clothingItemModelBoth.clothingItemModel?.name ?? Constants.unknown))
        : item.clothingItemModelBoth.clothingItemModel?.toDetailString(widget.optionalAnalysisResult)
        ?? (item.clothingItemModelBoth.clothingItemModel?.name ?? Constants.unknown);

    return details != Constants.unknown ? details.translatedSelectableText(
      context,
      localeLanguageCode: widget.vm.localeLanguageCode,
      style: Theme.of(context).textTheme.titleLarge,
    ) : SizedBox.shrink();
  }

  Widget storeContainer(ClothingItemFloorModel item) {
    if (enableExperimentalFeatures) {
      final experimentalModel = item.clothingItemModelBoth.clothingItemModelExperimental;
      if (experimentalModel != null &&
          experimentalModel.selectedStore != null &&
          experimentalModel.selectedStore!.isNotEmpty &&
          experimentalModel.selectedStore != Constants.unknown &&
          experimentalModel.stores.isNotEmpty) {
        return GestureDetector(
          onTap: () => showStorePicker(context, experimentalModel.stores),
          child: Container(
            clipBehavior: Constants.clipBehaviour,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.onSecondaryContainer.withAlpha(25),
                width: Constants.borderWidthMedium,
              ),
              borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium),
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
                Text(
                  experimentalModel.selectedStore!, // Safe because we checked != null && isNotEmpty
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    } else {
      return SizedBox.shrink();
    }
  }

  Widget priceContainer(ClothingItemFloorModel item) {
    if (enableExperimentalFeatures) {
      final experimentalModel = item.clothingItemModelBoth.clothingItemModelExperimental;
      if (experimentalModel != null &&
          experimentalModel.selectedStore != null &&
          experimentalModel.selectedStore!.isNotEmpty) {
        final price = experimentalModel.selectedStorePrice();
        if (price != Constants.unknown) {
          return Text(
            price.toFormattedPrice(),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      } else {
        return SizedBox.shrink();
      }
    } else {
      final model = item.clothingItemModelBoth.clothingItemModel;
      if (model != null && model.price != Constants.unknown) {
        return Text(
          model.price,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    }
  }

  Widget colorContainer(ClothingItemFloorModel item) {
    String colorName = enableExperimentalFeatures
        ? item.clothingItemModelBoth.clothingItemModelExperimental?.color
        ?? Constants.unknown
        : item.clothingItemModelBoth.clothingItemModel?.color
        ?? Constants.unknown;

    String colorHexCode = enableExperimentalFeatures
        ? item.clothingItemModelBoth.clothingItemModelExperimental?.colorHexCode
        ?? Constants.unknown
        : item.clothingItemModelBoth.clothingItemModel?.colorHexCode
        ?? Constants.unknown;

    return colorName != Constants.unknown ? GestureDetector(
        onDoubleTap: () {
          widget.vm.copyToClipboard(widget.parentContext, colorHexCode);
        },
        child: Container(
            clipBehavior: Constants.clipBehaviour,
            decoration: BoxDecoration(
                color: colorHexCode != Constants.unknown ? colorHexCode.toColor() : Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: colorHexCode != Constants.unknown ? (colorHexCode.toColor().isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(25)) : Theme.of(context).colorScheme.onSurface,
                  width: Constants.borderWidthLarge,
                ),
                borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium)
            ),
            padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 2
            ),
            child: colorName.translatedText(
                context,
                localeLanguageCode: widget.vm.localeLanguageCode,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorHexCode.toColor().isDark ? Colors.white : Colors.black)
            )
        )
    ) : SizedBox.shrink();
  }

  Widget imageSamples() {
    return widget.item.googleResults.isNotEmpty
        ? ClipRRect(
      borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium),
      clipBehavior: Constants.clipBehaviour,
      child: AspectRatio(
        aspectRatio: 4 / 3, // Optional: keep consistent image ratio
        child: PageView.builder(
          controller: PageController(),
          itemCount: widget.item.googleResults.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final result = widget.item.googleResults[index];
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
                        padding: const EdgeInsets.only(top: 16, left: 16),
                        icon: Image.asset(
                          "assets/images/expand.png",
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    )
        : GestureDetector(
      onTap: () => showFullScreenImage(context, widget.imagePath, false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium),
        clipBehavior: Constants.clipBehaviour,
        child: Stack(
          children: [
            Image.file(
              File(widget.imagePath),
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
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16),
                  child: Image.asset(
                    "assets/images/expand.png",
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Animate the left Checkbox and SizedBox appearance
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: widget.isSelecting
              ? Row(
            children: [
              Checkbox(
                value: widget.item.isSelected,
                onChanged: (bool? value) {
                  if (value != null) {
                    setState(() {
                      widget.item.isSelected = value;
                    });
                  }
                },
              ),
              const SizedBox(width: 16),
            ],
          )
              : const SizedBox.shrink(),
        ),

        Expanded(
            child: GestureDetector(
                onTap: () {
                  if (!widget.isSelecting) return;
                  setState(() {
                    widget.item.isSelected = !widget.item.isSelected;
                  });
                },
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    clipBehavior: Constants.clipBehaviour,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(Constants.cornerRadiusLarge),
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                            blurRadius: 3,
                            blurStyle: BlurStyle.outer,
                            offset: const Offset(3, 3)
                        )
                      ],
                      // Animated border
                      border: Border.all(
                          color: widget.item.isSelected
                              ? Theme.of(context).colorScheme.onSurface.withAlpha(25)
                              : Colors.transparent,
                          width: widget.item.isSelected ? 6 : 0
                      ),
                    ),
                    child: AbsorbPointer(
                        absorbing: widget.isSelecting,
                        child: GestureDetector(
                            onLongPress: () async {
                              final googleResults = widget.item.googleResults;
                              showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                ),
                                builder: (context) {
                                  return MoreBottomSheet(
                                      imagePath: widget.imagePath,
                                      googleResults: googleResults,
                                      clothingItemModelBoth: widget.item.clothingItemModelBoth,
                                      optionalAnalysisResult: widget.optionalAnalysisResult
                                  );
                                },
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    StackedAvatarBadge(profileImage: "assets/images/woman_1.png", badgeImage: "assets/images/stack.png", badgePadding: 10),
                                    IconButton(
                                        onPressed: () async {
                                          final googleResults = widget.item.googleResults;
                                          showModalBottomSheet(
                                            context: context,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                            ),
                                            builder: (context) {
                                              return MoreBottomSheet(
                                                  imagePath: widget.imagePath,
                                                  googleResults: googleResults,
                                                  clothingItemModelBoth: widget.item.clothingItemModelBoth,
                                                  optionalAnalysisResult: widget.optionalAnalysisResult,
                                                  customFuncOnSuccess: () {
                                                    widget.vm.loadWishlist();
                                                  }
                                              );
                                            },
                                          );
                                        },
                                        icon: Icon(Icons.arrow_outward_rounded, color: Theme.of(context).colorScheme.onSurface)
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
                                        imageSamples(),
                                        SizedBox(height: 16),
                                        Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4),
                                            child: Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      titleContainer(widget.item),
                                                      SizedBox(height: 16),
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Expanded(
                                                              child: SingleChildScrollView(
                                                                scrollDirection: Axis.horizontal,
                                                                clipBehavior: Constants.clipBehaviour,
                                                                child: Row(
                                                                    spacing: 8,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      colorContainer(widget.item),
                                                                      storeContainer(widget.item),
                                                                    ]
                                                                ),
                                                              )
                                                          ),
                                                          SizedBox(width: 16),
                                                          priceContainer(widget.item),
                                                        ],
                                                      )
                                                    ]
                                                )
                                            )
                                        )
                                      ],
                                    )
                                )
                              ],
                            )
                        )
                    )
                )
            )
        )
      ],
    );
  }

  // Select Source
  Future<void> selectStore(String value) async {
    setState(() {
      widget.item.clothingItemModelBoth.clothingItemModelExperimental!.setSelectedStore(value);
    });

    Navigator.pop(context);
  }

  // Show source selection sheet
  void showStorePicker(BuildContext context, List<StoreModel> modelList) {
    for (var model in modelList) {
      if (kDebugMode) {
        print('Store Name: ${model.name}, Price: ${model.price}');
      }
    }
    List<String> list = modelList.map((e) => e.name).toList();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        String selectedValue = widget.item.clothingItemModelBoth.clothingItemModelExperimental!.selectedStore!;
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
                  if (selectedIndex != initialIndex) selectStore(list[selectedIndex]);
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
}