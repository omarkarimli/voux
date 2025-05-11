import '../utils/constants.dart';

class StoreModel {
  final String name;
  final String price;

  StoreModel({required this.name, required this.price});

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      name: json[Constants.name],
      price: json[Constants.price],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      Constants.name: name,
      Constants.price: price,
    };
  }
}
