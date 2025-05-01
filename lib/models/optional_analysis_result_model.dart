import '../utils/constants.dart';

class OptionalAnalysisResult {
  final String gender;
  final bool isChild;
  final String rate;

  OptionalAnalysisResult({
    required this.gender,
    required this.isChild,
    required this.rate
  });

  // Deserialize from JSON
  factory OptionalAnalysisResult.fromJson(Map<String, dynamic> json) {
    return OptionalAnalysisResult(
      gender: json[Constants.gender],
      isChild: json[Constants.isChild],
      rate: json[Constants.rate]
    );
  }

  // Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      Constants.gender: gender,
      Constants.isChild: isChild,
      Constants.rate: rate
    };
  }
}
