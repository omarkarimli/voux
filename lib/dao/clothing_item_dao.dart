import 'package:floor/floor.dart';
import 'package:voux/models/clothing_item_floor_model.dart';

@dao
abstract class ClothingItemDao {
  @Query('SELECT * FROM ClothingItemFloorModel')
  Future<List<ClothingItemFloorModel>> getAllClothingItemFloorModels();

  @Query('SELECT * FROM ClothingItemFloorModel WHERE id = :id')
  Stream<ClothingItemFloorModel?> getClothingItemFloorModelById(int id);

  @Query('SELECT * FROM ClothingItemFloorModel WHERE details = :details')
  Stream<ClothingItemFloorModel?> getClothingItemFloorModelByDetail(String details);

  @Query('DELETE FROM ClothingItemFloorModel WHERE details = :details')
  Future<void> deleteClothingItemFloorModelByDetail(String details);

  @Query('DELETE FROM ClothingItemFloorModel')
  Future<void> deleteAllClothingItemFloorModels();

  @update
  Future<void> updateClothingItemFloorModel(ClothingItemFloorModel clothingItemModel);

  @insert
  Future<void> insertClothingItemFloorModel(ClothingItemFloorModel clothingItemModel);
}
