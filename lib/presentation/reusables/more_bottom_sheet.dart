import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../di/locator.dart';
import '../../utils/extensions.dart';
import '../../models/clothing_item_model.dart';
import '../../models/optional_analysis_result_model.dart';
import '../../utils/constants.dart';
import 'more_bottom_sheet_view_model.dart';

class MoreBottomSheet extends StatefulWidget {
  final String imagePath;
  final List<Map<String, String>> googleResults;
  final ClothingItemModel clothingItemModel;
  final OptionalAnalysisResult optionalAnalysisResult;

  const MoreBottomSheet({
    super.key,
    required this.imagePath,
    required this.googleResults,
    required this.clothingItemModel,
    required this.optionalAnalysisResult
  });

  @override
  _MoreBottomSheetState createState() => _MoreBottomSheetState();
}

class _MoreBottomSheetState extends State<MoreBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = MoreBottomSheetViewModel(
            clothingItemDao: locator.get()
        );
        viewModel.initAndCheckWishlist(widget.clothingItemModel);
        return viewModel;
      },
      child: Consumer<MoreBottomSheetViewModel>(
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
                    viewModel.isInWishlist ? Icons.bookmark : Icons.bookmark_border,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: Text(
                    viewModel.isInWishlist ? 'Remove from Wishlist' : 'Add to Wishlist',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onTap: viewModel.isLoading
                      ? null
                      : () {
                    viewModel.toggleWishlist(
                      imagePath: widget.imagePath,
                      googleResults: widget.googleResults,
                      clothingItemModel: widget.clothingItemModel,
                      optionalAnalysisResult: widget.optionalAnalysisResult,
                      onSuccess: (message) {
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
                ListTile(
                  leading: Icon(
                    Icons.explore_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: Text(
                    'Search in Web',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    searchInBrowser(widget.clothingItemModel
                        .toDetailString(widget.optionalAnalysisResult));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> searchInBrowser(String query) async {
    final Uri url = Uri.https('www.google.com', '/search', {'q': query});

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      context.showCustomSnackBar(Constants.error, "Could not launch $url");
    }
  }
}
