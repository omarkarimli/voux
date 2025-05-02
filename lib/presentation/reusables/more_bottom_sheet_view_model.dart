import 'package:flutter/material.dart';
import '../../dao/clothing_item_dao.dart';
import '../../models/clothing_item_floor_model.dart';
import '../../models/clothing_item_model.dart';
import '../../models/optional_analysis_result_model.dart';

class MoreBottomSheetViewModel extends ChangeNotifier {
  final ClothingItemDao clothingItemDao;

  MoreBottomSheetViewModel({
    required this.clothingItemDao
  });

  bool isLoading = true;
  bool isInWishlist = false;
  bool _initialized = false;

  Future<void> initAndCheckWishlist(ClothingItemModel model) async {
    if (_initialized) return;

    final item = await clothingItemDao
        .getClothingItemFloorModelByClothingItemModel(model)
        .first;

    isInWishlist = item != null;
    isLoading = false;
    _initialized = true;
    notifyListeners();
  }

  Future<void> toggleWishlist({
    required String imagePath,
    required List<Map<String, String>> googleResults,
    required ClothingItemModel clothingItemModel,
    required OptionalAnalysisResult optionalAnalysisResult,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      if (isInWishlist) {
        await clothingItemDao.deleteClothingItemFloorModelByClothingItemModel(clothingItemModel);
        isInWishlist = false;
      } else {
        final clothingItemFloorModel = ClothingItemFloorModel(
          null,
          imagePath,
          googleResults,
          clothingItemModel,
          optionalAnalysisResult,
        );
        await clothingItemDao.insertClothingItemFloorModel(clothingItemFloorModel);
        isInWishlist = true;
      }

      isLoading = false;
      notifyListeners();
      onSuccess.call(
        isInWishlist
            ? "Added to wishlist"
            : "Removed from wishlist"
      );
    } catch (e, stackTrace) {
      debugPrint("Error updating wishlist: $e\n$stackTrace");
      onError.call("Error updating wishlist");
    }
  }
}
