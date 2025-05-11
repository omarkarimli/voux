import 'clothing_item_model.dart';
import 'clothing_item_model_experimental.dart';

class ClothingItemModelBoth {
  final ClothingItemModel? clothingItemModel;
  final ClothingItemModelExperimental? clothingItemModelExperimental;

  ClothingItemModelBoth({
    required this.clothingItemModel,
    required this.clothingItemModelExperimental,
  });

  factory ClothingItemModelBoth.fromJson(Map<String, dynamic> json) {
    return ClothingItemModelBoth(
      clothingItemModel: json['clothingItemModel'] != null
          ? ClothingItemModel.fromJson(json['clothingItemModel'])
          : null,
      clothingItemModelExperimental: json['clothingItemModelExperimental'] != null
          ? ClothingItemModelExperimental.fromJson(json['clothingItemModelExperimental'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clothingItemModel': clothingItemModel?.toJson(),
      'clothingItemModelExperimental': clothingItemModelExperimental?.toJson(),
    };
  }
}
