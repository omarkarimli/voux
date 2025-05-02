import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../presentation/auth/auth_view_model.dart';
import '../presentation/detail/detail_view_model.dart';
import '../presentation/reusables/more_bottom_sheet_view_model.dart';
import '../dao/clothing_item_dao.dart';
import '../db/database.dart';
import '../presentation/wishlist/wishlist_view_model.dart';
import '../utils/constants.dart';
import '../presentation/home/home_view_model.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  locator.registerLazySingleton(() => database);

  final clothingItemDao = database.clothingItemDao;
  locator.registerLazySingleton(() => clothingItemDao);

  final prefs = await SharedPreferences.getInstance();
  locator.registerLazySingleton(() => prefs);

  locator.registerLazySingleton(() => FirebaseAuth.instance);
  locator.registerLazySingleton(() => FirebaseFirestore.instance);
  locator.registerFactory(() => GenerativeModel(model: Constants.geminiModel, apiKey: Constants.geminiApiKey));

  locator.registerFactory(() => HomeViewModel(
    model: locator<GenerativeModel>(),
    auth: locator<FirebaseAuth>(),
    firestore: locator<FirebaseFirestore>(),
    database: locator<AppDatabase>(),
  ));

  locator.registerFactory(() => AuthViewModel(
    prefs: locator<SharedPreferences>(),
    auth: locator<FirebaseAuth>(),
    firestore: locator<FirebaseFirestore>()
  ));

  locator.registerFactory(() => MoreBottomSheetViewModel(
    clothingItemDao: locator<ClothingItemDao>()
  ));

  locator.registerFactory(() => WishlistViewModel(
      clothingItemDao: locator<ClothingItemDao>()
  ));
}
