import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voux/dao/clothing_item_history_dao.dart';
import '../../dao/clothing_item_dao.dart';
import '../../models/clothing_item_floor_model.dart';
import '../../utils/constants.dart';
import '../../utils/extensions.dart';

class HistoryViewModel extends ChangeNotifier {
  final ClothingItemHistoryDao clothingItemHistoryDao;

  HistoryViewModel({
    required this.clothingItemHistoryDao
  });

  late List<ClothingItemFloorModel> wishlistItems = [];

  bool _isSelecting = false;
  bool get isSelecting => _isSelecting;

  String localeLanguageCode = 'en';

  Future<void> loadWishlist() async {
    wishlistItems = await clothingItemHistoryDao.getAllClothingItemFloorModels();

    notifyListeners(); // Only notify once
  }

  Future<void> setBoolSelecting(bool value) async {
    _isSelecting = value;
    notifyListeners();

    if (kDebugMode) {
      print("isSelecting: $_isSelecting");
    }
  }

  Future<void> removeSelectedItems() async {
    for (var item in wishlistItems) {
      item.isSelected = false;
    }
    notifyListeners();
  }

  Future<void> deleteSelectedItems({
    required Function(String) onSuccess,
    required Function(String) onError
  }) async {
    try {
      int numDeleteds = 0;
      for (var item in wishlistItems) {
        if (item.isSelected) {
          await clothingItemHistoryDao.deleteClothingItemFloorModelByClothingItemModelBoth(item.clothingItemModelBoth);
          numDeleteds++;
        }
      }

      if (numDeleteds == 0) {
        onError.call("No item was selected".tr());
        return;
      }

      wishlistItems.removeWhere((item) => item.isSelected);

      setBoolSelecting(false);
      removeSelectedItems();

      onSuccess.call("$numDeleteds ${"deleted".tr()}");
    } catch (e) {
      debugPrint("Error deleting selected items: $e");
      onError.call("Error deleting selected items".tr());
    }
    notifyListeners();
  }

  void copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    context.showCustomSnackBar(Constants.success, "Copied to clipboard".tr());
    notifyListeners();
  }
}