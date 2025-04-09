import 'dart:io';
import 'package:flutter/material.dart';
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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
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
                            StackedAvatarBadge(profileImage: "assets/images/woman_avatar.png", badgeImage: "assets/images/stack.png", badgePadding: 10),
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              child: IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(Constants.cornerRadiusMedium)),
                                    ),
                                    builder: (context) {
                                      return MoreBottomSheet(
                                          imagePath: item.imagePath,
                                          details: item.details,
                                          price: item.price,
                                          colorHexCode: item.colorHexCode
                                      );
                                    },
                                  ).then((_) {
                                    _loadWishlist(); // Refresh wishlist after closing bottom sheet
                                  });
                                },
                                icon: Icon(Icons.more_vert_rounded, color: Theme.of(context).colorScheme.onSurface),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Constants.cornerRadiusSmall),
                          child: Image.file(
                            File(item.imagePath),
                            width: double.infinity,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 16),
                        Padding(
                          padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SelectableText(item.details.chunkText(16).capitalizeFirst(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.normal)),
                                SelectableText(item.price.toFormattedPrice(), style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer))
                              ],
                            )
                        ),
                      ],
                    ),
                  )
                )
              );
            },
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
                  end: Alignment.center,
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
}
