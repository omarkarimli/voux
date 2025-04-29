import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voux/presentation/wishlist/clothing_item_wishlist_card.dart';
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
          body: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(left: 24, right: 24, top: MediaQuery.of(context).padding.top + 8, bottom: MediaQuery.of(context).padding.bottom + 48),
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
                          child: _buildWishlistItemsList(),
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
                      });
                    },
                  ),
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
                        "${vm.wishlistItems.length} items",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  )
              )
            ],
          ),
        );
      },
    );
  }

  // Function to build the list of wishlist items
  Widget _buildWishlistItemsList() {
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
            children: vm.wishlistItems
              .map((item) => ClothingItemWishlistCard(vm: vm, imagePath: item.imagePath, item: item, optionalAnalysisResult: item.optionalAnalysisResult))
              .toList(),
          );
  }
}
