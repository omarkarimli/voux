import 'package:floor/floor.dart';

@Entity(tableName: 'ClothingItemFloorModel')
class ClothingItemFloorModel {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: "details")  // Ensure this matches DB column name
  final String details;

  final String imagePath;
  final String price;
  final String colorHexCode;

  ClothingItemFloorModel(
      this.id,
      this.details,
      this.imagePath,
      this.price,
      this.colorHexCode,
  );
}
