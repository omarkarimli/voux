import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

  @override
  void initState() {
    super.initState();

    if (widget.item.clothingItemModel.stores.isNotEmpty) {
      widget.item.clothingItemModel.setSelectedStore(widget.item.clothingItemModel.stores[0].name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final item = widget.item;
    final details = item.clothingItemModel.toDetailString(widget.optionalAnalysisResult);
    print(details);

    return AnimatedSize(
      key: ValueKey(vm.isSelecting),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Row(
        children: [
          widget.isSelecting ? Row(
            children: [
              Checkbox(
                  value: item.isSelected,
                  onChanged: (bool? value) {
                    if (value != null) {
                      setState(() {
                        item.isSelected = value;
                      });
                    }
                  }
              ),
              const SizedBox(width: 16)
            ],
          ) : SizedBox.shrink(),

          Expanded(
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
                              clothingItemModel: item.clothingItemModel,
                              optionalAnalysisResult: widget.optionalAnalysisResult
                          );
                        },
                      );
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
                                                clothingItemModel: item.clothingItemModel,
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
                                      widget.item.googleResults.isNotEmpty
                                          ? Container(
                                        height: 96,
                                        clipBehavior: Constants.clipBehaviour,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium),
                                        ),
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
                                      )
                                          : GestureDetector(
                                          onTap: () => showFullScreenImage(context, widget.imagePath, false),
                                          child: Container(
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
                                                            padding: EdgeInsets.only(top: 16, left: 16),
                                                            child: Image.asset(
                                                              "assets/images/expand.png",
                                                              color: Theme.of(context).colorScheme.onSurface,
                                                              width: 24,
                                                              height: 24,
                                                            )
                                                        ),
                                                      )
                                                  )
                                                ],
                                              )
                                          )
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
                                                    SelectableText(
                                                        details,
                                                        style: Theme.of(context).textTheme.titleLarge
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
                                                                  spacing: 8,
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    GestureDetector(
                                                                        onTap: () {
                                                                          vm.copyToClipboard(item.clothingItemModel.colorHexCode);

                                                                          setState(() {
                                                                            widget.parentContext.showCustomSnackBar(Constants.success, "Copied to clipboard");
                                                                          });
                                                                        },
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
                                                                    if (item.clothingItemModel.selectedStore != null && item.clothingItemModel.selectedStore!.isNotEmpty)
                                                                      GestureDetector(
                                                                          onTap: () => showStorePicker(context, item.clothingItemModel.stores),
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
                                                                                    Text(item.clothingItemModel.selectedStore!, style: Theme.of(context).textTheme.bodySmall),
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
                                                        if (item.clothingItemModel.selectedStore != null && item.clothingItemModel.selectedStore!.isNotEmpty)
                                                          Text(
                                                              item.clothingItemModel.selectedStorePrice().toFormattedPrice(),
                                                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer)
                                                          )
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
                )
              )
          )
        ],
      )
    );
  }

  // Select Source
  Future<void> selectStore(String value) async {
    setState(() {
      widget.item.clothingItemModel.setSelectedStore(value);
    });

    Navigator.pop(context);
  }

  // Show source selection sheet
  void showStorePicker(BuildContext context, List<StoreModel> modelList) {
    for (var model in modelList) {
      print('Store Name: ${model.name}, Price: ${model.price}');
    }
    List<String> list = modelList.map((e) => e.name).toList();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        String selectedValue = widget.item.clothingItemModel.selectedStore!;
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
