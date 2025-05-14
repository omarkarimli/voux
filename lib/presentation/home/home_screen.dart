import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:voux/presentation/history/history_screen.dart';

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
      vm.getEnableExperimentalSharedPreference();
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
                  clothingItemBoths: vm.clothingItemBoths,
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
                    bottom: 48,
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
                              TextSpan(text: "Hello".tr()),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Image.asset(
                                      Theme.of(context).brightness == Brightness.dark
                                          ? 'assets/images/logo_dark.png'
                                          : 'assets/images/logo_light.png',
                                      width: 64,
                                      height: 64
                                  )
                                )
                              ),
                              TextSpan(text: "\n${"I hope you are".tr()}\n"),
                              TextSpan(text: "doing well".tr(), style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )
                      ),
                      const SizedBox(height: 28),
                      buildExploreCard(vm),
                      const SizedBox(height: 16),
                      buildButtonsRow(vm),
                      const SizedBox(height: 16),
                      buildStatsCard(vm),
                      const SizedBox(height: 16),
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge,
                      children: [
                        TextSpan(text: "${"Let's find".tr()} "),
                        TextSpan(text: "new style".tr(), style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
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
                          context.showCustomSnackBar(Constants.error, "You have reached limit. Upgrade to continue.".tr());
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
          GestureDetector(
            onTap: () {
                Navigator.pushNamed(context, UpgradeScreen.routeName);
            },
            child: Container(
              clipBehavior: Constants.clipBehaviour,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.all(Radius.circular(Constants.cornerRadiusLarge)),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                    blurStyle: BlurStyle.outer,
                    offset: Offset(3, 3),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  children: [
                    TextSpan(
                      text: "🚀  ${"Unlock".tr()} ",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: "Premium".tr()),
                  ],
                ),
              ),
            )
          ),
          Container(
            clipBehavior: Constants.clipBehaviour,
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.all(Radius.circular(Constants.cornerRadiusLarge)),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                  blurStyle: BlurStyle.outer,
                  offset: Offset(3, 3),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                    children: [
                      TextSpan(text: "🏆  ${"Explored".tr()} ", style: const TextStyle(fontWeight: FontWeight.w600)),
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      clipBehavior: Constants.clipBehaviour,
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, HistoryScreen.routeName),
            child: Padding(
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
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total explored".tr(), style: Theme.of(context).textTheme.bodyLarge),
                            SizedBox(height: 4),
                            Text("${vm.userModel?.currentAnalysisCount ?? 0} ${"images".tr()}", style: Theme.of(context).textTheme.headlineMedium),
                          ],
                        ),
                      )
                  ),
                ],
              ),
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
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          clipBehavior: Constants.clipBehaviour,
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
            padding: const EdgeInsets.only(
              top: 4,
              bottom: 4,
              right: 6,
              left: 24,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.headlineSmall,
                        children: [
                          TextSpan(
                              text: "${"Saved".tr()} "
                          ),
                          TextSpan(
                            text: "${vm.wishlistSize ?? 0} ${"items".tr()}",
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    )
                  )
                ),
                SizedBox(width: 16),
                StackedAvatarBadge(profileImage: "assets/images/woman_1.png", badgeImage: "assets/images/wishlist.png", badgePadding: 10),
              ],
            ),
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
              title: Text('Camera'.tr()),
              onTap: () async {
                Navigator.pop(context);
                final picked = await ImagePicker().pickImage(source: ImageSource.camera);
                if (picked != null) vm.analyzeImage(picked.path);
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.photo),
              title: Text('Gallery'.tr()),
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
