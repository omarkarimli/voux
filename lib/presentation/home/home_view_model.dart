import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voux/models/clothing_item_model_both.dart';
import 'package:voux/models/clothing_item_model_experimental.dart';

import '../../di/locator.dart';
import '../../db/database.dart';
import '../../models/clothing_item_model.dart';
import '../../models/optional_analysis_result_model.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';

class HomeViewModel extends ChangeNotifier {
  final GenerativeModel model;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final AppDatabase database;

  HomeViewModel({
    required this.model,
    required this.auth,
    required this.firestore,
    required this.database,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _imagePath;
  String? get imagePath => _imagePath;

  List<ClothingItemModelBoth> _clothingItemBoths = [];
  List<ClothingItemModelBoth> get clothingItemBoths => _clothingItemBoths;

  OptionalAnalysisResult? _optionalAnalysisResult;
  OptionalAnalysisResult? get optionalAnalysisResult => _optionalAnalysisResult;

  User? _user;
  User? get user => _user;

  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  bool _navigateToDetail = false;
  bool get navigateToDetail => _navigateToDetail;

  int? _wishlistSize;
  int? get wishlistSize => _wishlistSize;

  bool enableExperimentalFeatures = false;

  void getEnableExperimentalSharedPreference() {
    enableExperimentalFeatures = locator<SharedPreferences>().getBool(Constants.enableExperimentalFeatures) ?? false;
  }

  void resetNavigation() {
    _navigateToDetail = false;

    Future.microtask(() {
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;

    Future.microtask(() {
      notifyListeners();
    });
  }

  bool canAnalyze() {
    if (_userModel == null) return false;
    return _userModel!.currentAnalysisCount < _userModel!.analysisLimit;
  }

  void setLoading(bool value) {
    _isLoading = value;

    Future.microtask(() {
      notifyListeners();
    });
  }

  void setError(String message) {
    _errorMessage = message;

    Future.microtask(() {
      notifyListeners();
    });
  }

  void setNavigateToDetail(bool value) {
    _navigateToDetail = value;

    // // Postpone notifyListeners() to avoid calling it during build phase
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   notifyListeners();
    // });
    Future.microtask(() {
      notifyListeners();
    });
  }

  void setUser(User u) {
    _user = u;

    Future.microtask(() {
      notifyListeners();
    });
  }

  Future<void> fetchUserFromFirestore(String userId) async {
    resetNavigation();
    setLoading(true);
    try {
      final doc = await FirebaseFirestore.instance.collection(Constants.users).doc(userId).get();
      if (doc.exists && doc.data() != null) {
        _userModel = UserModel.fromFirestore(doc.data()!);
        _wishlistSize = await getWishlistSize();

        resetNavigation();
      } else {
        setError("User not found in firestore");
      }
    } catch (e) {
      setError("Failed to fetch user: $e");
    }
    setLoading(false);
  }

  Future<void> fetchUserFromAuth() async {
    resetNavigation();
    setLoading(true);

    try {
      if (auth.currentUser == null) {
        setError("User not found in auth");
        return;
      }
      setUser(auth.currentUser!);
      await fetchUserFromFirestore(auth.currentUser!.uid);
    } catch (e) {
      setError("Failed to fetch user: $e");
    } finally {
      setLoading(false);
    }
  }

  Future<int> getWishlistSize() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    return (await database.clothingItemDao.getAllClothingItemFloorModels()).length;
  }

  Future<void> analyzeImage(String path) async {
    if (_isLoading) return; // Prevent multiple triggers if already loading

    setLoading(true);

    try {
      final responses = await Future.wait([
        enableExperimentalFeatures ? analyzeGeneralExperimental(path) : analyzeGeneral(path),
        analyzeOptional(path),
      ]);

      _imagePath = path;

      late List<ClothingItemModelBoth> rBoth;
      if (enableExperimentalFeatures) {
        var r = responses[0] as List<ClothingItemModelExperimental>;
        rBoth = r.map((item) => ClothingItemModelBoth(
          clothingItemModel: null,
          clothingItemModelExperimental: item,
        )).toList();
      } else {
        var r = responses[0] as List<ClothingItemModel>;
        rBoth = r.map((item) => ClothingItemModelBoth(
          clothingItemModel: item,
          clothingItemModelExperimental: null,
        )).toList();
      }

      _clothingItemBoths = rBoth;
      _optionalAnalysisResult = responses[1] as OptionalAnalysisResult;

      if (kDebugMode) {
        print(_clothingItemBoths);
      }

      if (_clothingItemBoths.isEmpty) {
        setError("API response was empty or null".tr());
      } else {
        updateAnalysisCount();
        setNavigateToDetail(true);
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Failed to analyze image: $e");
      }
      setError("Failed to analyze image".tr());
    } finally {
      setLoading(false);
    }
  }

  void updateAnalysisCount() async {
    try {
      await locator<FirebaseFirestore>()
          .collection(Constants.users)
          .doc(user!.uid)
          .update({
        Constants.currentAnalysisCount: userModel!.currentAnalysisCount + 1,
      });
    } catch (e) {
      if (kDebugMode) {
        print("❌ Failed to update analysis count: $e");
      }
    }
  }

  Future<List<ClothingItemModel>> analyzeGeneral(String path) async {
    try {
      final imageBytes = await File(path).readAsBytes();
      final content = [
        Content.multi([
          TextPart(Constants.geminiPrompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      return parseResponse(response.text);
    } catch (e) {
      if (kDebugMode) {
        print("❌ _analyzeImage error: $e");
      }
      return [];
    }
  }

  Future<List<ClothingItemModelExperimental>> analyzeGeneralExperimental(String path) async {
    try {
      final imageBytes = await File(path).readAsBytes();
      final content = [
        Content.multi([
          TextPart(Constants.geminiPromptExperimental),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      return parseResponseExperimental(response.text);
    } catch (e) {
      if (kDebugMode) {
        print("❌ _analyzeImage error: $e");
      }
      return [];
    }
  }

  List<ClothingItemModel> parseResponse(String? text) {
    if (kDebugMode) {
      print("✅ Raw JSON Response: $text");
    }

    if (text == null || text.trim().isEmpty) return [];
    try {
      final cleaned = text.replaceAll('```', '').replaceAll('json', '').replaceAll('null', '"${Constants.unknown}"');
      final List<dynamic> jsonList = json.decode(cleaned);

      return jsonList.map((item) =>
           ClothingItemModel.fromJson(item)
      ).toList();
    } catch (e) {
      if (kDebugMode) {
        print("❌ JSON Parse Error: $e");
      }
      return [];
    }
  }

  List<ClothingItemModelExperimental> parseResponseExperimental(String? text) {
    if (kDebugMode) {
      print("✅ Raw JSON Response: $text");
    }

    if (text == null || text.trim().isEmpty) return [];
    try {
      final cleaned = text.replaceAll('```', '').replaceAll('json', '').replaceAll('null', '"${Constants.unknown}"');
      final List<dynamic> jsonList = json.decode(cleaned);

      return jsonList.map((item) =>
          ClothingItemModelExperimental.fromJson(item)
      ).toList();
    } catch (e) {
      if (kDebugMode) {
        print("❌ JSON Parse Error: $e");
      }
      return [];
    }
  }

  Future<OptionalAnalysisResult> analyzeOptional(String path) async {
    try {
      final imageBytes = await File(path).readAsBytes();
      final content = [
        Content.multi([
          TextPart(Constants.geminiOptionalPrompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      if (kDebugMode) {
        print("✅ Raw Optional Analysis Response: ${response.text}");
      }
      return _parseOptional(response.text);
    } catch (e) {
      if (kDebugMode) {
        print("❌ _analyzeOptional error: $e");
      }
      return OptionalAnalysisResult(gender: Constants.unknown, isChild: false, rate: Constants.unknown);
    }
  }

  OptionalAnalysisResult _parseOptional(String? text) {
    if (text == null || text.trim().isEmpty) {
      return OptionalAnalysisResult(gender: Constants.unknown, isChild: false, rate: Constants.unknown);
    }
    try {
      final match = RegExp(r'\{[\s\S]*?\}').firstMatch(text.replaceAll('```json', '').replaceAll('```', ''));
      if (match == null) return OptionalAnalysisResult(gender: Constants.unknown, isChild: false, rate: Constants.unknown);
      final jsonData = json.decode(match.group(0)!);
      return OptionalAnalysisResult(
        gender: jsonData[Constants.gender] ?? Constants.unknown,
        isChild: jsonData[Constants.isChild] ?? false,
        rate: jsonData[Constants.rate] ?? Constants.unknown
      );
    } catch (e) {
      if (kDebugMode) {
        print("❌ Parse Optional Error: $e");
      }
      return OptionalAnalysisResult(gender: Constants.unknown, isChild: false, rate: Constants.unknown);
    }
  }

}
