import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../dao/clothing_item_history_dao.dart';
import '../../models/clothing_item_floor_model.dart';

class HistoryMoreBottomSheetViewModel extends ChangeNotifier {
  final List<ClothingItemFloorModel> clothingItemFloorModels;
  final ClothingItemHistoryDao clothingItemHistoryDao;

  HistoryMoreBottomSheetViewModel({
    required this.clothingItemFloorModels,
    required this.clothingItemHistoryDao
  });

  Future<void> clearAllItems({
      required Function(String) onSuccess,
      required Function(String) onError
  }) async {
    try {
      if (clothingItemFloorModels.isEmpty) {
        onError.call("No items in history".tr());
      } else {
        await clothingItemHistoryDao.deleteAllClothingItemFloorModels();
        onSuccess.call("History cleared".tr());
      }

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint("Error updating history: $e\n$stackTrace");
      onError.call("Error updating history".tr());
    }
  }

  Future<void> selectItems({
    required Function(String) onSuccess,
    required Function(String) onError
  }) async {
    try {
      if (clothingItemFloorModels.isEmpty) {
        onError.call("No items in wishlist".tr());
      } else {
        onSuccess.call("");
      }
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint("Error updating wishlist: $e\n$stackTrace");
      onError.call("Error updating wishlist".tr());
    }
  }
}
