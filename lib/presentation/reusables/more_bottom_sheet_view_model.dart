import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../models/clothing_item_floor_model.dart';
import '../../models/optional_analysis_result_model.dart';
import '../../models/clothing_item_model_both.dart';
import '../../dao/clothing_item_dao.dart';

class MoreBottomSheetViewModel extends ChangeNotifier {
  final ClothingItemDao clothingItemDao;

  MoreBottomSheetViewModel({
    required this.clothingItemDao
  });

  bool isLoading = true;
  bool isInWishlist = false;
  bool _initialized = false;

  Future<void> initAndCheckWishlist(ClothingItemModelBoth model) async {
    if (_initialized) return;

    final item = await clothingItemDao
        .getClothingItemFloorModelByClothingItemModelBoth(model)
        .first;

    isInWishlist = item != null;
    isLoading = false;
    _initialized = true;
    notifyListeners();
  }

  Future<void> toggleWishlist({
    required String imagePath,
    required List<Map<String, String>> googleResults,
    required ClothingItemModelBoth clothingItemModelBoth,
    required OptionalAnalysisResult optionalAnalysisResult,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      if (isInWishlist) {
        await clothingItemDao.deleteClothingItemFloorModelByClothingItemModelBoth(clothingItemModelBoth);
        isInWishlist = false;
      } else {
        final clothingItemFloorModel = ClothingItemFloorModel(
          null,
          imagePath,
          googleResults,
          clothingItemModelBoth,
          optionalAnalysisResult
        );
        await clothingItemDao.insertClothingItemFloorModel(clothingItemFloorModel);
        isInWishlist = true;
      }

      isLoading = false;
      notifyListeners();
      onSuccess.call(
        isInWishlist
            ? "Added to wishlist".tr()
            : "Removed from wishlist".tr()
      );
    } catch (e, stackTrace) {
      debugPrint("Error updating wishlist: $e\n$stackTrace");
      onError.call("Error updating wishlist".tr());
    }
  }
}
