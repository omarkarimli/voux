class OptionalAnalysisResult {
  final String gender;
  final bool isChild;

  OptionalAnalysisResult({
    required this.gender,
    required this.isChild,
  });

  // Deserialize from JSON
  factory OptionalAnalysisResult.fromJson(Map<String, dynamic> json) {
    return OptionalAnalysisResult(
      gender: json['gender'],
      isChild: json['isChild'],
    );
  }

  // Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'isChild': isChild,
    };
  }
}
