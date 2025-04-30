class StoreModel {
  final String name;
  final String price;

  StoreModel({required this.name, required this.price});

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      name: json['name'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
}
