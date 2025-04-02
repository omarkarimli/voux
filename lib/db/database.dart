// database.dart
// for generation
// flutter clean
// flutter pub get
// flutter pub run build_runner build --delete-conflicting-outputs

// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../dao/clothing_item_dao.dart';
import '../models/clothing_item_floor_model.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [ClothingItemFloorModel])
abstract class AppDatabase extends FloorDatabase {
  ClothingItemDao get clothingItemDao;
}