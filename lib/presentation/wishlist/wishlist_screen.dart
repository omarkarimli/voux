import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voux/presentation/wishlist/clothing_item_wishlist_card.dart';
import 'package:voux/presentation/wishlist/wishlist_more_bottom_sheet.dart';
import 'package:voux/utils/extensions.dart';
import '../home/home_screen.dart';
import '../wishlist/wishlist_view_model.dart';
import '../../utils/constants.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  static const routeName = '/${Constants.wishlist}';

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late WishlistViewModel vm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    vm = Provider.of<WishlistViewModel>(context, listen: false);
    vm.loadWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          bottomNavigationBar: BottomAppBar(
            elevation: 3,
            color: Theme.of(context).colorScheme.surface,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    "${vm.wishlistItems.length} items",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: vm.isSelecting
                      ? IconButton(
                    onPressed: () {
                      vm.setBoolSelecting(false);
                      vm.removeSelectedItems();
                    },
                    icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onSurface),
                  )
                      : IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) {
                          return WishlistMoreBottomSheet(clothingItemFloorModels: vm.wishlistItems);
                        },
                      );
                    },
                    icon: Icon(Icons.more_horiz_rounded, color: Theme.of(context).colorScheme.onSurface),
                  )
                ),
                vm.isSelecting
                    ? Positioned(
                  left: 0,
                  child: IconButton(
                    onPressed: () {
                      vm.deleteSelectedItems(
                        onSuccess: (message) => context.showCustomSnackBar(Constants.success, message),
                        onError: (message) => context.showCustomSnackBar(Constants.error, message),
                      );
                    },
                    icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.onSurface),
                  )
                ) : SizedBox.shrink(),
              ],
            )
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(left: 24, right: 24, top: MediaQuery.of(context).padding.top + 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 72),
                        Text(
                          'Wishlist',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: buildWishlistItemsList(),
                        )
                      ],
                    ),
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
                        vm.setBoolSelecting(false);
                      });
                    },
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // Function to build the list of wishlist items
  Widget buildWishlistItemsList() {
    return vm.wishlistItems.isEmpty
        ? SizedBox(
            height: MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top+MediaQuery.of(context).padding.bottom + 272),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/empty.png", width: 128, height: 128),
                  Text("No items in wishlist", style: Theme.of(context).textTheme.bodyLarge)
                ],
              )
            )
          )
        : Column(
            spacing: 8,
            children: vm.wishlistItems.map((item) => ClothingItemWishlistCard(
                parentContext: context,
                vm: vm,
                isSelecting: vm.isSelecting,
                imagePath: item.imagePath,
                item: item,
                optionalAnalysisResult: item.optionalAnalysisResult
            )).toList(),
          );
  }
}
