import 'package:floor/floor.dart';
import '../models/clothing_item_model_both.dart';
import '../models/clothing_item_floor_model.dart';

@dao
abstract class ClothingItemDao {
  @Query('SELECT * FROM ClothingItemFloorModel')
  Future<List<ClothingItemFloorModel>> getAllClothingItemFloorModels();

  @Query('SELECT * FROM ClothingItemFloorModel WHERE id = :id')
  Stream<ClothingItemFloorModel?> getClothingItemFloorModelById(int id);

  @Query('SELECT * FROM ClothingItemFloorModel WHERE clothingItemModelBoth = :clothingItemModelBoth')
  Stream<ClothingItemFloorModel?> getClothingItemFloorModelByClothingItemModelBoth(ClothingItemModelBoth clothingItemModelBoth);

  @Query('DELETE FROM ClothingItemFloorModel WHERE id = :id')
  Future<void> deleteClothingItemFloorModelById(int id);

  @Query('DELETE FROM ClothingItemFloorModel WHERE clothingItemModelBoth = :clothingItemModelBoth')
  Future<void> deleteClothingItemFloorModelByClothingItemModelBoth(ClothingItemModelBoth clothingItemModelBoth);

  @Query('DELETE FROM ClothingItemFloorModel')
  Future<void> deleteAllClothingItemFloorModels();

  @update
  Future<void> updateClothingItemFloorModel(ClothingItemFloorModel clothingItemFloorModel);

  @insert
  Future<void> insertClothingItemFloorModel(ClothingItemFloorModel clothingItemFloorModel);
}
