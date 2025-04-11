import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/clothing_item_floor_model.dart';
import '../../../utils/extensions.dart';
import '../../db/database.dart';
import '../../utils/constants.dart';
import '../reusables/more_bottom_sheet.dart';
import '../reusables/stacked_avatar_badge.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  static const routeName = '/${Constants.wishlist}';

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<ClothingItemFloorModel> wishlistItems = [];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    final clothingItemDao = database.clothingItemDao;
    final items = await clothingItemDao.getAllClothingItemFloorModels();

    setState(() {
      wishlistItems = items;
    });
  }

  // Function to build the list of wishlist items
  Widget _buildWishlistItemsList() {
    return wishlistItems.isEmpty
        ? Center(child: Text("No items in wishlist", style: Theme.of(context).textTheme.bodyLarge))
        : ListView.builder(
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              final item = wishlistItems[index];
              return buildItemWidget(context, item);
            },
          );
  }

  Widget buildItemWidget(BuildContext context, ClothingItemFloorModel item) {
    final details = item.clothingItemModel.toDetailString(item.optionalAnalysisResult);
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
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) {
                          return MoreBottomSheet(
                              imagePath: item.imagePath,
                              googleResults: item.googleResults,
                              clothingItemModel: item.clothingItemModel,
                              optionalAnalysisResult: item.optionalAnalysisResult
                          );
                        },
                      ).then((_) {
                        _loadWishlist(); // Refresh wishlist after closing bottom sheet
                      });
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
                      item.googleResults.isNotEmpty ? Container(
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
                      ) : SizedBox.shrink(),
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
                                              onTap: () => copyToClipboard(context, item.clothingItemModel.colorHexCode),
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      color: item.clothingItemModel.colorHexCode.toColor(),
                                                      border: Border.all(
                                                        color: item.clothingItemModel.colorHexCode.toColor().isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(25),
                                                        width: Constants.borderWidth,
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
                                          )
                                        ],
                                      )
                                  ),
                                  SizedBox(width: 8),
                                  Text(item.clothingItemModel.price.toFormattedPrice(), style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer))
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: MediaQuery.of(context).padding.top + 8, bottom: MediaQuery.of(context).padding.bottom + 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 72),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Wishlist',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    // Wrap ListView with SizedBox with a fixed height
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 208,
                      child: _buildWishlistItemsList(),
                    )
                  ],
                ),
              )
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: 20,
                bottom: MediaQuery.of(context).padding.bottom + 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.primaryContainer
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Text(
                  "${wishlistItems.length} items",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          )
        ],
      ),
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
