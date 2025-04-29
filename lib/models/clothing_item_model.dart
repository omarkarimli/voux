import '../models/optional_analysis_result_model.dart';
import '../models/seller_source_model.dart';
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
  final List<SellerSourceModel> sellerSources;

  // Added to store the selected source
  String? selectedSource;

  ClothingItemModel({
    required this.name,
    required this.color,
    required this.colorHexCode,
    required this.size,
    required this.type,
    required this.material,
    required this.brand,
    required this.model,
    required this.sellerSources,

    this.selectedSource
  });

  // Optionally, add a method to convert JSON response from the API
  factory ClothingItemModel.fromJson(Map<String, dynamic> json) {
    return ClothingItemModel(
      name: json['name'],
      color: json['color'],
      colorHexCode: json['colorHexCode'],
      size: json['size'],
      type: json['type'],
      material: json['material'],
      brand: json['brand'],
      model: json['model'],
      sellerSources: (json['sellerSources'] as List<dynamic>? ?? [])
          .map((sellerSourceJson) => SellerSourceModel.fromJson(sellerSourceJson))
          .toList(),

      selectedSource: json['selectedSource']
    );
  }

  // Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color,
      'colorHexCode': colorHexCode,
      'size': size,
      'type': type,
      'material': material,
      'brand': brand,
      'model': model,
      'sellerSources': sellerSources.map((s) => s.toJson()).toList(),

      'selectedSource': selectedSource,
    };
  }

  String toDetailString(OptionalAnalysisResult optionalAnalysisResult) {
    final attributes = [
      optionalAnalysisResult.gender,
      optionalAnalysisResult.isChild ? 'Child' : '',
      material,
      size,
      brand,
      model,
      name
    ].where((attr) => attr != Constants.unknown).join(' ');
    final details = attributes;

    return details.capitalizeFirst();
  }

  // Get the price for the selected source
  String selectedSourcePrice() {
    if (selectedSource != null) {
      final source = sellerSources.firstWhere(
            (s) => s.name == selectedSource,
        orElse: () => SellerSourceModel(name: Constants.unknown, price: Constants.unknown),
      );
      return source.price.toFormattedPrice();
    }
    return "0";
  }

  // Set the selected source
  void setSelectedSource(String sourceName) {
    selectedSource = sourceName;
  }
}
