import 'dart:convert';
import 'package:floor/floor.dart';
import '../models/clothing_item_model.dart';

class ClothingItemModelConverter extends TypeConverter<ClothingItemModel, String> {
  @override
  ClothingItemModel decode(String databaseValue) {
    return ClothingItemModel.fromJson(jsonDecode(databaseValue));
  }

  @override
  String encode(ClothingItemModel value) {
    return jsonEncode(value.toJson());
  }
}
