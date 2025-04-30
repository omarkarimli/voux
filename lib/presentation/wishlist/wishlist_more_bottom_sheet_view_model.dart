import 'package:flutter/material.dart';
import '../../dao/clothing_item_dao.dart';
import '../../models/clothing_item_floor_model.dart';

class WishlistMoreBottomSheetViewModel extends ChangeNotifier {
  final List<ClothingItemFloorModel> clothingItemFloorModels;
  final ClothingItemDao clothingItemDao;

  WishlistMoreBottomSheetViewModel({
    required this.clothingItemFloorModels,
    required this.clothingItemDao
  });

  Future<void> clearAllItems({
      required Function(String) onSuccess,
      required Function(String) onError
  }) async {
    try {
      if (clothingItemFloorModels.isEmpty) {
        onError.call("Wishlist is empty");
      } else {
        await clothingItemDao.deleteAllClothingItemFloorModels();
        onSuccess.call("Wishlist cleared");
      }

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint("Error updating wishlist: $e\n$stackTrace");
      onError.call("Error updating wishlist");
    }
  }

  Future<void> selectItems({
    required Function(String) onSuccess,
    required Function(String) onError
  }) async {
    try {
      if (clothingItemFloorModels.isEmpty) {
        onError.call("Wishlist is empty");
      } else {
        onSuccess.call("");
      }
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint("Error updating wishlist: $e\n$stackTrace");
      onError.call("Error updating wishlist");
    }
  }
}
