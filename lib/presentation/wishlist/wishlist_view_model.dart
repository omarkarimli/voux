import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../db/database.dart';
import '../../models/clothing_item_floor_model.dart';
import '../../utils/constants.dart';

class WishlistViewModel extends ChangeNotifier {

  late List<ClothingItemFloorModel> wishlistItems = [];

  Future<void> loadWishlist() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    final clothingItemDao = database.clothingItemDao;
    final items = await clothingItemDao.getAllClothingItemFloorModels();

    wishlistItems = items;

    Future.microtask(() {
      notifyListeners();
    });
  }
}
