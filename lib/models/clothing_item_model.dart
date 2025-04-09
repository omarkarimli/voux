class ClothingItemModel {
  final String name;
  final String color;
  final String size;
  final String type;
  final String material;
  final String brand;
  final String model;
  final String price;

  ClothingItemModel({
    required this.name,
    required this.color,
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
      size: json['size'],
      type: json['type'],
      material: json['material'],
      brand: json['brand'],
      model: json['model'],
      price: json['price'],
    );
  }
}
