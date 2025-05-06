import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/clothing_item_model.dart';
import '../../di/locator.dart';

class ChatViewModel extends ChangeNotifier {
  final List<ClothingItemModel> clothingItems;

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

  ChatViewModel({
    required this.clothingItems
  }) {
    sendInitialMessage();
    generateExampleQuestions();

    textController.addListener(() => notifyListeners());
    sheetController.addListener(onSizeChanged);
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
    if (isGeneratingExamples || clothingItems.isEmpty) return;

    isGeneratingExamples = true;
    notifyListeners();

    final itemNames = clothingItems.take(5).map((e) => e.name).join(', ');
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
    sendMessage(buildInitialPrompt());
  }

  String buildInitialPrompt() {
    final names = clothingItems.map((e) => e.name).toList();
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