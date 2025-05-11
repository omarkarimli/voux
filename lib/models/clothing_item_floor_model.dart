import 'package:floor/floor.dart';
import '../models/clothing_item_model_both.dart';
import '../models/optional_analysis_result_model.dart';

@Entity(tableName: 'ClothingItemFloorModel')
class ClothingItemFloorModel {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String imagePath;
  final List<Map<String, String>> googleResults;
  final ClothingItemModelBoth clothingItemModelBoth;
  final OptionalAnalysisResult optionalAnalysisResult;

  bool isSelected = false;

  ClothingItemFloorModel(
      this.id,
      this.imagePath,
      this.googleResults,
      this.clothingItemModelBoth,
      this.optionalAnalysisResult
  );
}
