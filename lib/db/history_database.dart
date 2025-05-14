// database.dart
// for generation
// flutter clean
// flutter pub get
// flutter pub run build_runner build --delete-conflicting-outputs

// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../dao/clothing_item_history_dao.dart';
import '../models/clothing_item_floor_model.dart';
import '../models/clothing_item_model_both.dart';
import 'clothing_item_model_both_converter.dart';
import 'google_results_converter.dart';
import 'optional_analysis_result_converter.dart';

part 'history_database.g.dart'; // the generated code will be there

@TypeConverters([
  ClothingItemModelBothConverter,
  OptionalAnalysisResultConverter,
  GoogleResultsConverter
])
@Database(version: 1, entities: [ClothingItemFloorModel])
abstract class HistoryAppDatabase extends FloorDatabase {
  ClothingItemHistoryDao get clothingItemHistoryDao;
}