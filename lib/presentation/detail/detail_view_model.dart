import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../models/clothing_item_model.dart';
import '../../utils/constants.dart';

class DetailViewModel extends ChangeNotifier {
  List<ClothingItemModel> _clothingItems = [];
  List<ClothingItemModel> get clothingItems => _clothingItems;

  set clothingItems(List<ClothingItemModel> items) {
    _clothingItems = items;
    calculateTotalPrice();
    notifyListeners();
  }

  double _totalPrice = 0.0;
  double get totalPrice => _totalPrice;

  void calculateTotalPrice() {
    _totalPrice = _clothingItems.fold(
      0.0,
      (sum, item) => sum + (double.tryParse(item.selectedStorePrice()) ?? 0.0),
    );
    print("Updated totalPrice: $_totalPrice");
    notifyListeners();
  }

  Future<List<Map<String, String>>> fetchGoogleImages(String query) async {
    const String apiKey = Constants.cseApiKey;
    const String cx = Constants.cseId;
    const int numOfImgs = Constants.numOfImgsPlus;

    final Uri url = Uri.parse(
      'https://www.googleapis.com/customsearch/v1?q=$query&cx=$cx&searchType=image&num=$numOfImgs&key=$apiKey',
    );

    try {
      final response = await http.get(url);
      print("Google API Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] == null) return [];

        final List<Map<String, String>> results = [];

        for (var item in data['items']) {
          results.add({
            'imageUrl': item['link'] ?? '',
            'productUrl': item['image']['contextLink'] ?? '',
          });
        }

        return results;
      } else {
        print('Google Search API Error: ${response.body}');
        return []; // ← Don't throw, just return an empty list
      }
    } catch (e) {
      print('Exception in fetchGoogleImages: $e');
      return []; // ← Same here
    }
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }
}
