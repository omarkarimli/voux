import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/clothing_item_model.dart';
import '../../di/locator.dart';

class ChatViewModel extends ChangeNotifier {
  double minChildSize = 0.125;
  double maxChildSize = 0.85;
  final DraggableScrollableController sheetController = DraggableScrollableController();

  final FocusNode textFieldFocusNode = FocusNode();
  final TextEditingController textController = TextEditingController();
  final List<ChatMessage> messages = [];
  final List<ClothingItemModel> clothingItems;

  bool showInput = false;
  bool isMinimized = true;
  bool isLoading = false;
  bool shouldCancel = false;

  ChatViewModel({
    required this.clothingItems
  }) {
    sendInitialMessage();
    textController.addListener(() => notifyListeners());
    textFieldFocusNode.addListener(_onFocusChanged);
    sheetController.addListener(onSizeChanged);
  }

  void _onFocusChanged() {
    // When the input field is focused, stop the scrolling
    if (textFieldFocusNode.hasFocus) {
      // Disable scroll when focused
      sheetController.jumpTo(maxChildSize);
      
      sheetController.animateTo(
        maxChildSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void onSizeChanged() {
    final isExpanded = sheetController.size > 0.3;
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
    textFieldFocusNode.removeListener(_onFocusChanged);
    textFieldFocusNode.dispose();
    sheetController.removeListener(onSizeChanged);
    sheetController.dispose();
    textController.dispose();
    super.dispose();
  }

  void sendInitialMessage() {
    sendMessage(buildInitialPrompt());
  }

  String buildInitialPrompt() {
    final names = clothingItems.map((e) => e.name).toList();
    if (names.length > 5) {
      return "List includes ${names.take(5).join(', ')} and more. What are their prices and alternatives?";
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
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}
