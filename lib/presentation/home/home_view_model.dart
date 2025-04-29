import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:voux/di/locator.dart';

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

  List<ClothingItemModel> _clothingItems = [];
  List<ClothingItemModel> get clothingItems => _clothingItems;

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
        _analyzeImage(path),
        _analyzeOptional(path),
      ]);

      _imagePath = path;
      _clothingItems = responses[0] as List<ClothingItemModel>;
      _optionalAnalysisResult = responses[1] as OptionalAnalysisResult;

      print(_clothingItems);

      if (_clothingItems.isEmpty) {
        setError("API response was empty or null");
      } else {
        updateAnalysisCount();
        setNavigateToDetail(true);
      }
    } catch (e) {
      setError("Failed to analyze image: $e");
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
      print("❌ Failed to update analysis count: $e");
    }
  }

  Future<List<ClothingItemModel>> _analyzeImage(String path) async {
    try {
      final imageBytes = await File(path).readAsBytes();
      final content = [
        Content.multi([
          TextPart(Constants.geminiPrompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      return _parseResponse(response.text);
    } catch (e) {
      print("❌ _analyzeImage error: $e");
      return [];
    }
  }

  List<ClothingItemModel> _parseResponse(String? text) {
    print("✅ Raw JSON Response: $text");

    if (text == null || text.trim().isEmpty) return [];
    try {
      final cleaned = text.replaceAll('```', '').replaceAll('json', '').replaceAll('null', '"${Constants.unknown}"');
      final List<dynamic> jsonList = json.decode(cleaned);
      return jsonList.map((item) => ClothingItemModel.fromJson(item)).toList();
    } catch (e) {
      print("❌ JSON Parse Error: $e");
      return [];
    }
  }

  Future<OptionalAnalysisResult> _analyzeOptional(String path) async {
    try {
      final imageBytes = await File(path).readAsBytes();
      final content = [
        Content.multi([
          TextPart(Constants.geminiOptionalPrompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      return _parseOptional(response.text);
    } catch (e) {
      print("❌ _analyzeOptional error: $e");
      return OptionalAnalysisResult(gender: Constants.unknown, isChild: false);
    }
  }

  OptionalAnalysisResult _parseOptional(String? text) {
    if (text == null || text.trim().isEmpty) {
      return OptionalAnalysisResult(gender: Constants.unknown, isChild: false);
    }
    try {
      final match = RegExp(r'\{[\s\S]*?\}').firstMatch(text.replaceAll('```json', '').replaceAll('```', ''));
      if (match == null) return OptionalAnalysisResult(gender: Constants.unknown, isChild: false);
      final jsonData = json.decode(match.group(0)!);
      return OptionalAnalysisResult(
        gender: jsonData["gender"] ?? Constants.unknown,
        isChild: jsonData["is_child"] ?? false,
      );
    } catch (e) {
      print("❌ Parse Optional Error: $e");
      return OptionalAnalysisResult(gender: Constants.unknown, isChild: false);
    }
  }

}
