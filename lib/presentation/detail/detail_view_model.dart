import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voux/dao/clothing_item_history_dao.dart';
import '../../models/clothing_item_floor_model.dart';
import '../../models/clothing_item_model_both.dart';
import '../../di/locator.dart';
import '../../utils/constants.dart';
import '../../utils/extensions.dart';

class DetailViewModel extends ChangeNotifier {
  final List<ClothingItemModelBoth> clothingItemBoths;

  DetailViewModel({
    required this.clothingItemBoths
  });

  double _totalPrice = 0.0;
  double get totalPrice => _totalPrice;

  bool enableExperimentalFeatures = false;
  String localeLanguageCode = 'en';

  void initialize(BuildContext context) {
    enableExperimentalFeatures = locator<SharedPreferences>().getBool(Constants.enableExperimentalFeatures) ?? false;
    localeLanguageCode = context.locale.languageCode;

    calculateTotalPrice();
  }

  void calculateTotalPrice() {
    _totalPrice = clothingItemBoths.fold(
      0.0,
          (sum, item) => sum +
          (double.tryParse(
            enableExperimentalFeatures
                ? (item.clothingItemModelExperimental?.selectedStorePrice() ?? "0.0")
                : (item.clothingItemModel?.price ?? "0.0"),
          ) ??
              0.0),
    );

    if (kDebugMode) {
      print("Updated totalPrice: $_totalPrice");
    }

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
      if (kDebugMode) {
        print("Google API Response: ${response.statusCode} - ${response.body}");
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data[Constants.items] == null) return [];

        final List<Map<String, String>> results = [];

        for (var item in data[Constants.items]) {
          results.add({
            Constants.imageUrl: item[Constants.link] ?? '',
            Constants.productUrl: item[Constants.image][Constants.contextLink] ?? '',
          });
        }

        return results;
      } else {
        if (kDebugMode) {
          print('Google Search API Error: ${response.body}');
        }
        return []; // ← Don't throw, just return an empty list
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception in fetchGoogleImages: $e');
      }
      return []; // ← Same here
    }
  }

  void copyToClipboard(BuildContext context, String text) async{
    Clipboard.setData(ClipboardData(text: text));
    context.showCustomSnackBar(Constants.success, "Copied to clipboard".tr());
    notifyListeners();
  }
}
