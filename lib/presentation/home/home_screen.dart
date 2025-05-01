import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/optional_analysis_result_model.dart';
import '../wishlist/wishlist_screen.dart';
import '../../utils/extensions.dart';
import '../settings/settings_screen.dart';
import '../upgrade/upgrade_screen.dart';
import '../../utils/constants.dart';
import '../anim/anim_transition_route.dart';
import '../detail/detail_screen.dart';
import '../reusables/stacked_avatar_badge.dart';
import 'home_view_model.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/${Constants.home}';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel vm;
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      vm = Provider.of<HomeViewModel>(context, listen: false);
      vm.fetchUserFromAuth();
      initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, _) {
        if (vm.navigateToDetail == true) {
          // Delay navigation to the next frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.push(
              context,
              animTransitionRoute(
                DetailScreen(
                  imagePath: vm.imagePath!,
                  clothingItems: vm.clothingItems,
                  optionalAnalysisResult: vm.optionalAnalysisResult ??
                      OptionalAnalysisResult(
                        gender: Constants.unknown,
                        isChild: false,
                        rate: Constants.unknown
                      ),
                ),
              ),
            ).then((_) {
              vm.fetchUserFromFirestore(vm.user!.uid);
              vm.resetNavigation(); // <-- Create this function in ViewModel
            });
          });
        }

        if (vm.errorMessage != null) {
          final error = vm.errorMessage!;
          context.showCustomSnackBar(Constants.error, "Error: $error");
          Future.microtask(() => vm.clearError());
        }

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: AbsorbPointer(
            absorbing: vm.isLoading,
            child: Stack(
              children: [
                Positioned(
                  top: -228,
                  right: 0,
                  left: 0,
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.surface,
                        Colors.transparent
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      'assets/images/abstract_1.png',
                      height: 512,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: MediaQuery.of(context).padding.top + 16,
                    bottom: 64,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.settings_rounded, color: Theme.of(context).colorScheme.onSurface),
                            onPressed: () => Navigator.pushNamed(context, SettingsScreen.routeName),
                          ),
                        ),
                      ),
                      const SizedBox(height: 128),
                      FittedBox(
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(height: 1.4),
                            children: [
                              const TextSpan(text: "Hello "),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Image.asset(
                                    Theme.of(context).brightness == Brightness.dark
                                        ? 'assets/images/logo_dark.png'
                                        : 'assets/images/logo_light.png',
                                    width: 64,
                                    height: 64
                                )
                              ),
                              const TextSpan(text: " dear\n"),
                              const TextSpan(text: "I hope you are\n"),
                              const TextSpan(text: "doing well", style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )
                      ),
                      const SizedBox(height: 16),
                      buildExploreCard(vm),
                      const SizedBox(height: 16),
                      buildButtonsRow(vm),
                      const SizedBox(height: 16),
                      buildStatsCard(vm),
                      buildWishlistCard()
                    ],
                  ),
                ),
                if (vm.isLoading)
                  Center(
                    child: Card(
                      color: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium)),
                      clipBehavior: Constants.clipBehaviour,
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CupertinoActivityIndicator(
                          radius: 20.0,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      )
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildExploreCard(HomeViewModel vm) {
    return Container(
      clipBehavior: Constants.clipBehaviour,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(42),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withAlpha(5),
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constants.cornerRadiusLarge)),
          clipBehavior: Constants.clipBehaviour,
          color: Theme.of(context).colorScheme.surface,
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, left: 24, right: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge,
                    children: const [
                      TextSpan(text: "Let's find "),
                      TextSpan(text: "new style", style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Material(
                  elevation: 1,
                  shape: const CircleBorder(),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: IconButton(
                      icon: Icon(Icons.arrow_outward_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer),
                      onPressed: () {
                        if (!vm.isLoading && vm.canAnalyze()) {
                          showImageSourceSheet(context, vm);
                        } else {
                          context.showCustomSnackBar("Limit reached", "You have reached limit. Upgrade to continue.");
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }

  Widget buildButtonsRow(HomeViewModel vm) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 12,
        children: [
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, UpgradeScreen.routeName);
            },
            clipBehavior: Constants.clipBehaviour,
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium)),
                backgroundColor: Theme.of(context).colorScheme.surface
            ),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                children: [
                  TextSpan(
                    text: "🚀 Unlock ",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: "Premium"),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Define what happens when the button is pressed
            },
            clipBehavior: Constants.clipBehaviour,
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium)),
                backgroundColor: Theme.of(context).colorScheme.surface
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                    children: [
                      TextSpan(text: "🏆  Explored ", style: const TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(
                          text: "${vm.userModel?.currentAnalysisCount ?? 0}/${vm.userModel?.analysisLimit ?? 0}"
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget buildStatsCard(HomeViewModel vm) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      clipBehavior: Constants.clipBehaviour,
      elevation: 3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StackedAvatarBadge(profileImage: "assets/images/woman_1.png", badgeImage: "assets/images/ai_search.png"),
                  ],
                ),
                SizedBox(height: 22),
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total explored", style: Theme.of(context).textTheme.bodyLarge),
                      SizedBox(height: 4),
                      Text("${vm.userModel?.currentAnalysisCount ?? 0} images", style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 32,
            bottom: 32,
            child: Image.asset(
              width: 172,
              height: 172,
              "assets/images/abstract_2.png"
            )
          )
        ],
      ),
    );
  }

  Widget buildWishlistCard() {
    return GestureDetector(
        onTap: () => Navigator.pushNamed(context, WishlistScreen.routeName),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          clipBehavior: Constants.clipBehaviour,
          elevation: 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 8,
                  right: 8,
                  left: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.headlineSmall,
                            children: [
                              TextSpan(
                                  text: "Saved "
                              ),
                              TextSpan(
                                text: "${vm.wishlistSize ?? 0} items",
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                        StackedAvatarBadge(profileImage: "assets/images/woman_1.png", badgeImage: "assets/images/wishlist.png", badgePadding: 10),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        )
    );
  }

  void showImageSourceSheet(BuildContext context, HomeViewModel vm) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
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
              leading: const Icon(CupertinoIcons.camera),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await ImagePicker().pickImage(source: ImageSource.camera);
                if (picked != null) vm.analyzeImage(picked.path);
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.photo),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (picked != null) vm.analyzeImage(picked.path);
              },
            ),
          ],
        ),
      ),
    );
  }
}
