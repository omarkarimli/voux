import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voux/utils/extensions.dart';
import '../../dao/clothing_item_dao.dart';
import '../../db/database.dart';
import '../../models/clothing_item_floor_model.dart';
import '../../utils/constants.dart';

class MoreBottomSheet extends StatefulWidget {
  final String details;
  final String imagePath;
  final String price;
  final String colorHexCode;

  const MoreBottomSheet({
    super.key,
    required this.details,
    required this.imagePath,
    required this.price,
    required this.colorHexCode,
  });

  @override
  _MoreBottomSheetState createState() => _MoreBottomSheetState();
}

class _MoreBottomSheetState extends State<MoreBottomSheet> {
  late AppDatabase database;
  late ClothingItemDao clothingItemDao;
  bool isLoading = true;
  bool isInWishlist = false;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    clothingItemDao = database.clothingItemDao;
    await _checkWishlist();
  }

  Future<void> _checkWishlist() async {
    clothingItemDao
        .getClothingItemFloorModelByDetail(widget.details)
        .listen((item) {
      setState(() {
        isInWishlist = item != null;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        left: 8,
        right: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              isInWishlist ? Icons.bookmark : Icons.bookmark_border,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              isInWishlist ? 'Remove from Wishlist' : 'Add to Wishlist',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            onTap: isLoading ? null : _toggleWishlist,
          ),
          ListTile(
            leading: Icon(Icons.arrow_outward_rounded, color: Theme.of(context).colorScheme.onSurface),
            title: Text('Search in Web', style: Theme.of(context).textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context);
              _searchInBrowser(widget.details);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _searchInBrowser(String query) async {
    final Uri url = Uri.https('www.google.com', '/search', {'q': query});

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      context.showCustomSnackBar(Constants.error, "Could not launch $url");
    }
  }

  Future<void> _toggleWishlist() async {
    print("Toggled wishlist");
    try {
      if (isInWishlist) {
        await clothingItemDao.deleteClothingItemFloorModelByDetail(widget.details);
        context.showCustomSnackBar(Constants.success, "Removed from wishlist");
      } else {
        final clothingItemFloorModel = ClothingItemFloorModel(null, widget.details, widget.imagePath, widget.price, widget.colorHexCode);
        await clothingItemDao.insertClothingItemFloorModel(clothingItemFloorModel);
        context.showCustomSnackBar(Constants.success, "Added to wishlist");
      }
      await _checkWishlist();
    } catch (e) {
      context.showCustomSnackBar(Constants.error, "Error updating wishlist");
    } finally {
      Navigator.pop(context);
    }
  }
}
