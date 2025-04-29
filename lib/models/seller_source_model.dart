class SellerSourceModel {
  final String name;
  final String price;

  SellerSourceModel({required this.name, required this.price});

  factory SellerSourceModel.fromJson(Map<String, dynamic> json) {
    return SellerSourceModel(
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
