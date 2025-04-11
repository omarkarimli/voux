import 'dart:convert';
import 'package:floor/floor.dart';
import '../models/optional_analysis_result_model.dart';

class OptionalAnalysisResultConverter extends TypeConverter<OptionalAnalysisResult, String> {
  @override
  OptionalAnalysisResult decode(String databaseValue) {
    return OptionalAnalysisResult.fromJson(jsonDecode(databaseValue));
  }

  @override
  String encode(OptionalAnalysisResult value) {
    return jsonEncode(value.toJson());
  }
}
