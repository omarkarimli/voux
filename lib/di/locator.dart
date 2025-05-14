import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';
import 'package:voux/dao/clothing_item_history_dao.dart';
import 'package:voux/db/history_database.dart';

import '../presentation/auth/auth_view_model.dart';
import '../presentation/detail/detail_view_model.dart';
import '../presentation/history/history_view_model.dart';
import '../presentation/reusables/more_bottom_sheet_view_model.dart';
import '../dao/clothing_item_dao.dart';
import '../db/database.dart';
import '../presentation/wishlist/wishlist_view_model.dart';
import '../utils/constants.dart';
import '../presentation/home/home_view_model.dart';
import '../utils/translation_cache.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  locator.registerLazySingleton(() => database);

  final historyDatabase = await $FloorHistoryAppDatabase.databaseBuilder('history_database.db').build();
  locator.registerLazySingleton(() => historyDatabase);

  final clothingItemDao = database.clothingItemDao;
  locator.registerLazySingleton(() => clothingItemDao);

  final clothingItemHistoryDao = historyDatabase.clothingItemHistoryDao;
  locator.registerLazySingleton(() => clothingItemHistoryDao);

  final prefs = await SharedPreferences.getInstance();
  locator.registerLazySingleton(() => prefs);

  final translator = GoogleTranslator();
  locator.registerLazySingleton(() => translator);

  final translationCache = TranslationCache();
  locator.registerLazySingleton(() => translationCache);

  locator.registerLazySingleton(() => FirebaseAuth.instance);
  locator.registerLazySingleton(() => FirebaseFirestore.instance);
  locator.registerFactory(() => GenerativeModel(model: Constants.geminiModel, apiKey: Constants.geminiApiKey));

  locator.registerFactory(() => HomeViewModel(
    model: locator<GenerativeModel>(),
    auth: locator<FirebaseAuth>(),
    firestore: locator<FirebaseFirestore>(),
    database: locator<AppDatabase>(),
  ));

  locator.registerFactory(() => DetailViewModel(
    clothingItemBoths: []
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

  locator.registerFactory(() => HistoryViewModel(
      clothingItemHistoryDao: locator<ClothingItemHistoryDao>()
  ));
}
