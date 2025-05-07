import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voux/presentation/wishlist/wishlist_view_model.dart';
import '../../utils/extensions.dart';
import '../../di/locator.dart';
import '../../models/clothing_item_floor_model.dart';
import '../../utils/constants.dart';
import 'wishlist_more_bottom_sheet_view_model.dart';

class WishlistMoreBottomSheet extends StatefulWidget {
  final List<ClothingItemFloorModel> clothingItemFloorModels;

  const WishlistMoreBottomSheet({
    super.key,
    required this.clothingItemFloorModels
  });

  @override
  _WishlistMoreBottomSheetState createState() => _WishlistMoreBottomSheetState();
}

class _WishlistMoreBottomSheetState extends State<WishlistMoreBottomSheet> {
  @override
  Widget build(BuildContext context) {
    // WishlistViewModel
    final wishlistVm = Provider.of<WishlistViewModel>(context, listen: false);

    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = WishlistMoreBottomSheetViewModel(
            clothingItemFloorModels: widget.clothingItemFloorModels,
            clothingItemDao: locator.get()
        );
        return viewModel;
      },
      child: Consumer<WishlistMoreBottomSheetViewModel>(
        builder: (context, viewModel, child) {
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
                    Icons.done_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: Text(
                    'Select'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onTap: () {
                    // Select items from wishlist
                    viewModel.selectItems(
                      onSuccess: (message) {
                        wishlistVm.setBoolSelecting(true);

                        Navigator.pop(context);
                        if (message.isNotEmpty) {
                          context.showCustomSnackBar(Constants.success, message);
                        }
                      },
                      onError: (message) {
                        Navigator.pop(context);
                        context.showCustomSnackBar(Constants.error, message);
                      },
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.clear_all_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: Text(
                    'Clear all'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onTap: () {
                    // Clear all items from wishlist
                    viewModel.clearAllItems(
                      onSuccess: (message) {
                        wishlistVm.loadWishlist();

                        Navigator.pop(context);
                        context.showCustomSnackBar(Constants.success, message);
                      },
                      onError: (message) {
                        Navigator.pop(context);
                        context.showCustomSnackBar(Constants.error, message);
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
