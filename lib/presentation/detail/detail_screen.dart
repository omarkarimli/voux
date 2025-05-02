import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../detail/detail_view_model.dart';
import '../home/home_screen.dart';
import '../../models/optional_analysis_result_model.dart';
import '../../utils/constants.dart';
import '../reusables/report_bottom_sheet.dart';
import '../../models/clothing_item_model.dart';
import '../../utils/extensions.dart';
import '../reusables/stacked_text_badge.dart';
import 'chat_bottom_sheet.dart';
import 'clothing_item_card.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      final vm = Provider.of<DetailViewModel>(context, listen: false);
      vm.clothingItems = widget.clothingItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DetailViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Stack(
              children: [
                // Abstract
                Positioned(
                  top: 0,
                  right: 0,
                  child: Image.asset(
                    width: 332,
                    height: 332,
                    'assets/images/abstract_2.png',
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
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: 488,
                                    maxHeight: 512
                                  ),
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
                                )
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
                                      if (widget.optionalAnalysisResult.rate != Constants.unknown)
                                        Container(
                                            width: 48,
                                            height: 48,
                                            clipBehavior: Constants.clipBehaviour,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium),
                                              color: Theme.of(context).colorScheme.tertiary,
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                                widget.optionalAnalysisResult.rate,
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onTertiary)
                                            )
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
                                      StackedTextBadge(profileImage: "assets/images/woman_1.png", badgeImage: "assets/images/hanger.png", title: "+${widget.clothingItems.length}"),
                                      SizedBox(width: 16),
                                      if (vm.totalPrice > 0)
                                        SelectableText(vm.totalPrice.toStringAsFixed(2).toFormattedPrice(), style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer)),
                                    ]
                                ),
                                SizedBox(height: 24),
                                Column(
                                  spacing: 16,
                                  children: widget.clothingItems
                                      .map((item) => ClothingItemCard(
                                    vm: vm,
                                    imagePath: widget.imagePath,
                                    item: item,
                                    optionalAnalysisResult: widget.optionalAnalysisResult,
                                  ))
                                      .toList(),
                                )
                              ],
                            )
                        ),
                        SizedBox(height: 160)
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

                // Chat
                ChatBottomSheetWrapper(clothingItems: widget.clothingItems)
              ],
            )
        );
      },
    );
  }
}
