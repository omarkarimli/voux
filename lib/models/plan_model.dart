class PlanModel {
  final String name;
  final double price;
  final List<String> features;
  final bool isCurrentPlan;

  PlanModel({
    required this.name,
    required this.price,
    required this.features,
    required this.isCurrentPlan,
  });

  // Define copyWith method to create a new PlanModel with updated values
  PlanModel copyWith({
    String? name,
    double? price,
    List<String>? features,
    bool? isCurrentPlan,
  }) {
    return PlanModel(
      name: name ?? this.name,
      price: price ?? this.price,
      features: features ?? this.features,
      isCurrentPlan: isCurrentPlan ?? this.isCurrentPlan,
    );
  }
}
