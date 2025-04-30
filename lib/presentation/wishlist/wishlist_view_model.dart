import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../dao/clothing_item_dao.dart';
import '../../models/clothing_item_floor_model.dart';

class WishlistViewModel extends ChangeNotifier {
  final ClothingItemDao clothingItemDao;

  WishlistViewModel({
    required this.clothingItemDao
  });

  late List<ClothingItemFloorModel> wishlistItems = [];

  bool _isSelecting = false;
  bool get isSelecting => _isSelecting;

  Future<void> loadWishlist() async {
    wishlistItems = await clothingItemDao.getAllClothingItemFloorModels();

    notifyListeners(); // Only notify once
  }

  Future<void> setBoolSelecting(bool value) async {
    _isSelecting = value;
    notifyListeners();
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
          await clothingItemDao.deleteClothingItemFloorModelByClothingItemModel(item.clothingItemModel);
          numDeleteds++;
        }
      }
      wishlistItems.removeWhere((item) => item.isSelected);

      setBoolSelecting(false);
      removeSelectedItems();

      onSuccess.call("$numDeleteds items deleted");

      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting selected items: $e");
      onError.call("Error deleting selected items");
    }
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }
}
