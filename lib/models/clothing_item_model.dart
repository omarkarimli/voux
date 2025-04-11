import 'package:voux/models/optional_analysis_result_model.dart';
import 'package:voux/utils/extensions.dart';

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
  final String price;

  ClothingItemModel({
    required this.name,
    required this.color,
    required this.colorHexCode,
    required this.size,
    required this.type,
    required this.material,
    required this.brand,
    required this.model,
    required this.price,
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
      price: json['price'],
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
      'price': price,
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
}
