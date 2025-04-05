import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/clothing_item_model.dart';
import '../../models/optional_analysis_result_model.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

abstract class HomeEvent {}

class AnalyzeImageEvent extends HomeEvent {
  final String imagePath;

  AnalyzeImageEvent(this.imagePath);
}

abstract class HomeState {}

class HomeInitialState extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeSuccessState extends HomeState {
  final String imagePath;
  final List<ClothingItemModel> clothingItems;
  final OptionalAnalysisResult optionalAnalysisResult;

  HomeSuccessState(this.imagePath, this.clothingItems, this.optionalAnalysisResult);
}

class HomeFailureState extends HomeState {
  final String errorMessage;

  HomeFailureState(this.errorMessage);
}

class FetchUserEvent extends HomeEvent {
  final String userId;

  FetchUserEvent(this.userId);
}

class HomeUserSuccessState extends HomeState {
  final UserModel user;

  HomeUserSuccessState(this.user);
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final String apiKey = Constants.geminiApiKey;

  HomeBloc() : super(HomeInitialState()) {
    on<AnalyzeImageEvent>(_onAnalyzeImage);
    on<FetchUserEvent>(_onFetchUser);
  }

  Future<void> _onFetchUser(FetchUserEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState());

    try {
      final userDoc = FirebaseFirestore.instance.collection(Constants.users).doc(event.userId);
      final docSnapshot = await userDoc.get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        UserModel user = UserModel.fromFirestore(docSnapshot.data()!);
        emit(HomeUserSuccessState(user));
      } else {
        emit(HomeFailureState("User not found"));
      }
    } catch (e) {
      print("❌ Error fetching user: $e");
      emit(HomeFailureState("Failed to fetch user: $e"));
    }
  }

  Future<void> _onAnalyzeImage(AnalyzeImageEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState());
    try {
      final responses = await Future.wait([
        _analyzeImage(event.imagePath),
        _analyzeOptional(event.imagePath)
      ]);

      final List<ClothingItemModel>? clothingItems = responses[0] as List<ClothingItemModel>?;
      final optionalAnalysisResult = responses[1] as OptionalAnalysisResult;

      if (clothingItems != null && clothingItems.isNotEmpty) {
        emit(HomeSuccessState(event.imagePath, clothingItems, optionalAnalysisResult));
        print("✅ API Response: $clothingItems"); // Debugging log -> Success
      } else {
        emit(HomeFailureState("API response was empty or null"));
      }
    } catch (e, stacktrace) {
      print("❌ Error analyzing image: $e");
      print(stacktrace);
      emit(HomeFailureState("Failed to analyze image: $e"));
    }
  }

  Future<List<ClothingItemModel>> _analyzeImage(String imagePath) async {
    try {
      final model = GenerativeModel(
        model: Constants.geminiModel,
        apiKey: apiKey,
      );

      final imageBytes = await File(imagePath).readAsBytes();

      final content = [
        Content.multi([
          TextPart(Constants.geminiPrompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);

      return _parseResponse(response.text);
    } catch (e) {
      print("❌ API Call Error: $e");
      return [];
    }
  }

  List<ClothingItemModel> _parseResponse(String? responseText) {
    print("📝 Raw API Response: $responseText");

    if (responseText == null || responseText.trim().isEmpty) {
      print("❌ Empty or null response from Gemini API");
      return [];
    }

    try {
      final String jsonString = responseText.replaceAll('```', '').replaceAll('json', '').replaceAll('null', '"${Constants.unknown}"').trim();
      print("📝 Cleared JSON: $jsonString");

      // Parse JSON
      final List<dynamic> jsonList = json.decode(jsonString);

      // Convert JSON to List<ClothingItemModel>
      return jsonList
          .map((item) => ClothingItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("❌ JSON Parsing Error: $e");
      return [];
    }
  }

  Future<OptionalAnalysisResult> _analyzeOptional(String imagePath) async {
    try {
      final model = GenerativeModel(
        model: Constants.geminiModel,
        apiKey: apiKey,
      );

      final imageBytes = await File(imagePath).readAsBytes();

      final content = [
        Content.multi([
          TextPart(Constants.geminiOptionalPrompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);

      return _parseOptional(response.text);
    } catch (e) {
      print("❌ API Call Error: $e");
      return OptionalAnalysisResult(
        gender: Constants.unknown,
        isChild: false,
      );
    }
  }

  OptionalAnalysisResult _parseOptional(String? responseText) {
    print("📝 Raw API Response: $responseText");

    if (responseText == null || responseText.trim().isEmpty) {
      print("❌ Empty or null response from Gemini API");
      return OptionalAnalysisResult(
        gender: Constants.unknown,
        isChild: false,
      );
    }

    try {
      // Clean code block wrappers
      String cleaned = responseText
          .replaceAll(RegExp(r'```(json)?'), '')
          .replaceAll('```', '')
          .trim();

      // Extract JSON
      final jsonMatch = RegExp(r'\{[\s\S]*?\}').firstMatch(cleaned);
      if (jsonMatch == null) {
        print("❌ No valid JSON object found in response");
        return OptionalAnalysisResult(
          gender: Constants.unknown,
          isChild: false,
        );
      }

      final jsonString = jsonMatch.group(0)!;
      print("📝 Extracted JSON: $jsonString");

      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final gender = (jsonData["gender"] is String) ? jsonData["gender"] as String : Constants.unknown;
      final isChild = (jsonData["is_child"] is bool) ? jsonData["is_child"] as bool : false;

      return OptionalAnalysisResult(
        gender: gender,
        isChild: isChild,
      );
    } catch (e) {
      print("❌ JSON Parsing Error: $e");
      return OptionalAnalysisResult(
        gender: Constants.unknown,
        isChild: false,
      );
    }
  }
}
