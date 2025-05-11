import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';
import '../../models/clothing_item_model_both.dart';
import '../../di/locator.dart';
import '../../utils/constants.dart';

class ChatViewModel extends ChangeNotifier {
  final List<ClothingItemModelBoth> clothingItemBoths;

  double minChildSize = 0.125;
  double maxChildSize = 0.85;

  final DraggableScrollableController sheetController = DraggableScrollableController();
  final TextEditingController textController = TextEditingController();

  final List<ChatMessage> messages = [];
  List<String> exampleQuestions = [];

  bool isGeneratingExamples = false;
  bool showInput = false;
  bool isMinimized = true;
  bool isLoading = false;
  bool shouldCancel = false;

  bool enableExperimentalFeatures = false;

  String localeLanguageCode = 'en';
  final translator = GoogleTranslator();
  Map<String, String> cachedTranslations = {};

  ChatViewModel({
    required this.clothingItemBoths
  }) {
    enableExperimentalFeatures = locator<SharedPreferences>().getBool(Constants.enableExperimentalFeatures) ?? false;
    localeLanguageCode = locator<SharedPreferences>().getString(Constants.language) ?? 'en';

    sendInitialMessage();
    generateExampleQuestions();

    textController.addListener(() => notifyListeners());
    sheetController.addListener(onSizeChanged);
  }

  Future<String> getTranslatedText(String text) async {
    if (cachedTranslations.containsKey(text)) {
      return cachedTranslations[text]!;
    }

    if (localeLanguageCode != "en") {
      try {
        final translation = await translator.translate(text, to: localeLanguageCode);
        cachedTranslations[text] = translation.text;
        return translation.text;
      } catch (_) {
        return text; // fallback to the original text if translation fails
      }
    } else {
      return text;
    }
  }

  void onSizeChanged() {
    final isExpanded = sheetController.size > 0.45;
    final isMinimizedCopy = (sheetController.size - minChildSize).abs() < 0.01;

    final inputChanged = showInput != isExpanded;
    final minimizedChanged = isMinimized != isMinimizedCopy;

    if (inputChanged || minimizedChanged) {
      showInput = isExpanded;
      isMinimized = isMinimizedCopy;

      notifyListeners();
    }
  }

  void setControllerText(String text) {
    textController.text = text;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();

    sheetController.removeListener(onSizeChanged);
    sheetController.dispose();
    textController.dispose();
  }

  Future<void> generateExampleQuestions() async {
    if (isGeneratingExamples || clothingItemBoths.isEmpty) return;

    isGeneratingExamples = true;
    notifyListeners();

    final itemNames = clothingItemBoths.take(5).map(
            (e) =>
            enableExperimentalFeatures ? e.clothingItemModelExperimental!.name : e.clothingItemModel!.name
    ).join(', ');
    final prompt = "Based on the following clothing items: $itemNames, give 3 example questions a user might ask about them. Keep them short and helpful.";

    try {
      final content = [Content.text(prompt)];
      final response = await locator<GenerativeModel>().generateContent(content);
      final text = response.text ?? "";

      // Parse the model response into a list
      exampleQuestions = text
          .split(RegExp(r'\n|•|-')) // Split on newlines or bullet points
          .map((q) => q.trim())
          .where((q) => q.isNotEmpty)
          .take(3)
          .toList();
    } catch (_) {
      exampleQuestions = ["What should I wear this with?", "Are there cheaper alternatives?", "What style does this fit?"];
    }

    isGeneratingExamples = false;
    notifyListeners();
  }

  void sendInitialMessage() {
    var m = buildInitialPrompt();
    if (m.isNotEmpty) {
      sendMessage(buildInitialPrompt());
    }
  }

  String buildInitialPrompt() {

    final names = clothingItemBoths.map(
        (e) =>
        enableExperimentalFeatures
            ? (e.clothingItemModelExperimental?.name ?? "")
            : (e.clothingItemModel?.name ?? "")
    ).toList();

    if (names.isEmpty) return "";

    if (names.length > 5) {
      return "List includes ${names.take(5).join(', ')} and more. What are their prices and alternatives? Don't do numbering!";
    }
    return "${names.join(', ')} how much price is each? and give alternatives, write compactly";
  }

  Future<void> sendMessage(String message) async {
    if (message.isEmpty || isLoading || message.length > 512) return;

    messages.add(ChatMessage(text: message, isUser: true));
    textController.clear();
    isLoading = true;
    shouldCancel = false;
    notifyListeners();

    try {
      final response = await _think(message);
      if (!shouldCancel) {
        messages.add(ChatMessage(text: response, isUser: false));
      }
    } catch (_) {
      messages.add(ChatMessage(text: "Error occurred", isUser: false));
    }

    isLoading = false;
    notifyListeners();
  }

  Future<String> _think(String message) async {
    final content = [Content.multi([TextPart(message)])];

    try {
      final response = await Future.any([
        locator<GenerativeModel>().generateContent(content),
        Future.delayed(const Duration(seconds: 10), () => throw TimeoutException("Timeout")),
      ]);

      if (shouldCancel) {
        return "Thinking was stopped by user.";
      }

      return (response).text ?? "No response text.";
    } on TimeoutException {
      return "Request timed out. Please try again.";
    } catch (e) {
      return "Error occurred: ${e.toString()}";
    }
  }

  void stopThinking() {
    if (isLoading) {
      shouldCancel = true;
      isLoading = false;
      messages.add(ChatMessage(text: "Thinking was stopped.", isUser: false));
      notifyListeners();
    }
  }

  void clearMessages() {
    messages.clear();
    notifyListeners();
  }

  void clearInput() {
    textController.clear();
    notifyListeners();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}