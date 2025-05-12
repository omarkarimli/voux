import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../reusables/stacked_avatar_badge.dart';
import '../reusables/more_bottom_sheet.dart';
import '../../models/store_model.dart';
import '../../models/clothing_item_model_both.dart';
import '../../models/optional_analysis_result_model.dart';
import '../../utils/extensions.dart';
import '../../utils/constants.dart';
import '../detail/detail_view_model.dart';

class ClothingItemCard extends StatefulWidget {
  final DetailViewModel vm;
  final String imagePath;
  final ClothingItemModelBoth item;
  final OptionalAnalysisResult optionalAnalysisResult;

  const ClothingItemCard({
    super.key,
    required this.vm,
    required this.optionalAnalysisResult,
    required this.item,
    required this.imagePath,
  });

  @override
  State<ClothingItemCard> createState() => _ClothingItemCardState();
}

class _ClothingItemCardState extends State<ClothingItemCard> {

  bool enableExperimentalFeatures = false;

  @override
  void initState() {
    super.initState();

    enableExperimentalFeatures = widget.item.clothingItemModelExperimental != null;

    if (enableExperimentalFeatures && widget.item.clothingItemModelExperimental!.stores.isNotEmpty) {
      widget.item.clothingItemModelExperimental!.setSelectedStore(widget.item.clothingItemModelExperimental!.stores[0].name);
    }
  }

  // Select Source
  Future<void> selectStore(String value) async {
    setState(() {
      widget.item.clothingItemModelExperimental!.setSelectedStore(value);
    });

    // ✅ Trigger total price recalculation
    widget.vm.calculateTotalPrice();

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
        String selectedValue = widget.item.clothingItemModelExperimental!.selectedStore!;
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
                  children: list.map((store) {
                    return Center(child: Text(store, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.normal)));
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

  Future<void> openLink(BuildContext context, String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      context.showCustomSnackBar(Constants.error, "Could not launch".tr());
      throw Exception('Could not launch $url');
    }
  }

  void showFullScreenImage(BuildContext context, String imageUrl) {
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

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final item = widget.item;
    final details = enableExperimentalFeatures
        ? item.clothingItemModelExperimental!.toDetailString(widget.optionalAnalysisResult)
        : item.clothingItemModel!.toDetailString(widget.optionalAnalysisResult);

    if (kDebugMode) {
      print(details);
    }

    String colorHexCode = enableExperimentalFeatures ? item.clothingItemModelExperimental!.colorHexCode : item.clothingItemModel!.colorHexCode;
    String colorName = enableExperimentalFeatures ? item.clothingItemModelExperimental!.color : item.clothingItemModel!.color;

    return GestureDetector(
        onLongPress: () async {
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
                  clothingItemModelBoth: item,
                  optionalAnalysisResult: widget.optionalAnalysisResult
              );
            },
          );
        },
        child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.all(Radius.circular(Constants.cornerRadiusLarge)),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
                  blurStyle: BlurStyle.outer,
                  offset: Offset(3, 3),
                  blurRadius: 3,
                ),
              ],
            ),
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
                                    clothingItemModelBoth: item,
                                    optionalAnalysisResult: widget.optionalAnalysisResult
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
                                if (kDebugMode) {
                                  print('Error: ${snapshot.error}');
                                }
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
                                        onDoubleTap: () => openLink(context, result['productUrl']!),
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
                                                      onPressed: () => showFullScreenImage(context, result['imageUrl']!),
                                                      padding: EdgeInsets.only(top: 16, left: 16),
                                                      icon: Image.asset(
                                                          "assets/images/expand.png",
                                                          color: Theme.of(context).colorScheme.onSurface,
                                                          width: 24,
                                                          height: 24,
                                                      )
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
                                if (kDebugMode) {
                                  print('No images found');
                                }
                                return SizedBox.shrink();
                              }
                            },
                          ),
                          SizedBox(height: 16),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    details.translatedSelectableText(
                                      context,
                                      localeLanguageCode: vm.localeLanguageCode,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              clipBehavior: Constants.clipBehaviour,
                                              child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (colorHexCode != Constants.unknown) ...[
                                                      GestureDetector(
                                                          onDoubleTap: () => vm.copyToClipboard(context, colorHexCode),
                                                          child: Container(
                                                              clipBehavior: Constants.clipBehaviour,
                                                              decoration: BoxDecoration(
                                                                  color: colorHexCode.toColor(),
                                                                  border: Border.all(
                                                                    color: colorHexCode.toColor().isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(25),
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
                                                                localeLanguageCode: vm.localeLanguageCode,
                                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorHexCode.toColor().isDark ? Colors.white : Colors.black)
                                                              )
                                                          )
                                                      ),
                                                      SizedBox(width: 8),
                                                    ],

                                                    if (enableExperimentalFeatures && item.clothingItemModelExperimental!.selectedStore != null && item.clothingItemModelExperimental!.selectedStore!.isNotEmpty)
                                                      GestureDetector(
                                                          onTap: () => showStorePicker(context, item.clothingItemModelExperimental!.stores),
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
                                                                    Text(item.clothingItemModelExperimental!.selectedStore!, style: Theme.of(context).textTheme.bodySmall),
                                                                    SizedBox(width: 4),
                                                                    Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.onSecondaryContainer, size: 16)
                                                                  ]
                                                              )
                                                          )
                                                      )
                                                  ]
                                              ),
                                            )
                                        ),
                                        SizedBox(width: 16),

                                        if (enableExperimentalFeatures &&
                                            item.clothingItemModelExperimental!.selectedStore != null &&
                                            item.clothingItemModelExperimental!.selectedStore!.isNotEmpty)
                                          Text(
                                              "\$${item.clothingItemModelExperimental!.selectedStorePrice()}",
                                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer)
                                          ),

                                        if (!enableExperimentalFeatures &&
                                            item.clothingItemModel!.price != Constants.unknown)
                                          Text(
                                              "\$${item.clothingItemModel!.price}",
                                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer)
                                          ),
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
              ),
            )
        )
    );
  }
}
