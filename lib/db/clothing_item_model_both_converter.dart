import 'dart:convert';
import 'package:floor/floor.dart';
import '../models/clothing_item_model_both.dart';

class ClothingItemModelBothConverter extends TypeConverter<ClothingItemModelBoth, String> {
  @override
  ClothingItemModelBoth decode(String databaseValue) {
    return ClothingItemModelBoth.fromJson(jsonDecode(databaseValue));
  }

  @override
  String encode(ClothingItemModelBoth value) {
    return jsonEncode(value.toJson());
  }
}
