import 'package:voux/utils/constants.dart';

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
      gender: json[Constants.gender],
      isChild: json[Constants.isChild],
    );
  }

  // Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      Constants.gender: gender,
      Constants.isChild: isChild,
    };
  }
}
