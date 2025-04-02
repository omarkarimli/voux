import 'package:floor/floor.dart';

@Entity(tableName: 'ClothingItemFloorModel')
class ClothingItemFloorModel {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: "details")  // Ensure this matches DB column name
  final String details;

  final String imagePath;

  ClothingItemFloorModel(
      this.id,
      this.details,
      this.imagePath
  );
}
