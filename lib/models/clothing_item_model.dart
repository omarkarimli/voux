import '../models/optional_analysis_result_model.dart';
import '../models/store_model.dart';
import '../utils/extensions.dart';
import '../utils/constants.dart';

class ClothingItemModel {
  final String name;
  final String color;
  final String colorHexCode;
  final String size;
  final String type;
  final String material;
  final String brand;
  final String model;
  final List<StoreModel> stores;

  // Added to store the selected source
  String? selectedStore;

  ClothingItemModel({
    required this.name,
    required this.color,
    required this.colorHexCode,
    required this.size,
    required this.type,
    required this.material,
    required this.brand,
    required this.model,
    required this.stores,

    this.selectedStore
  });

  // Optionally, add a method to convert JSON response from the API
  factory ClothingItemModel.fromJson(Map<String, dynamic> json) {
    return ClothingItemModel(
      name: json[Constants.name],
      color: json[Constants.color],
      colorHexCode: json[Constants.colorHexCode],
      size: json[Constants.size],
      type: json[Constants.type],
      material: json[Constants.material],
      brand: json[Constants.brand],
      model: json[Constants.model],
      stores: (json[Constants.stores] as List<dynamic>? ?? [])
          .map((storeJson) => StoreModel.fromJson(storeJson))
          .toList(),

      selectedStore: json[Constants.selectedStore]
    );
  }

  // Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      Constants.name: name,
      Constants.color: color,
      Constants.colorHexCode: colorHexCode,
      Constants.size: size,
      Constants.type: type,
      Constants.material: material,
      Constants.brand: brand,
      Constants.model: model,
      Constants.stores: stores.map((s) => s.toJson()).toList(),
      Constants.selectedStore: selectedStore,
    };
  }

  String toDetailString(OptionalAnalysisResult optionalAnalysisResult) {
    final attributes = [
      optionalAnalysisResult.gender,
      optionalAnalysisResult.isChild ? Constants.child : '',
      material,
      size,
      brand,
      model,
      name
    ].where((attr) => attr != Constants.unknown).join(' ');
    final details = attributes;

    return details.capitalizeFirst();
  }

  // Get the price for the selected store
  String selectedStorePrice() {
    if (selectedStore != null) {
      final store = stores.firstWhere(
            (s) => s.name == selectedStore,
        orElse: () => StoreModel(name: Constants.unknown, price: Constants.unknown),
      );
      return store.price;
    }
    return "0";
  }

  // Set the selected source
  void setSelectedStore(String storeName) {
    selectedStore = storeName;
  }
}
