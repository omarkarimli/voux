import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/clothing_item_model.dart';
import '../../di/locator.dart';

class ChatBottomSheetViewModel extends ChangeNotifier {
  final ScrollController scrollController = ScrollController();
  bool isAtBottom = true;

  final TextEditingController textController = TextEditingController();
  final List<ChatMessage> messages = [];
  final List<ClothingItemModel> clothingItems;

  bool isLoading = false;
  bool shouldCancel = false;

  ChatBottomSheetViewModel({
    required this.clothingItems
  });

  void initialize() {
    sendInitialMessage();

    textController.addListener(() {
      notifyListeners();
    });

    scrollController.addListener(() {
      final isAtBottomCopy = scrollController.offset <= 50; // close to bottom (which is actually top due to reverse)
      if (isAtBottom != isAtBottomCopy) {
        isAtBottom = isAtBottomCopy;
        notifyListeners();
      }
    });
  }

  void setControllerText(String text) {
    textController.text = text;
    notifyListeners();
  }

  @override
  void dispose() {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isAtBottom) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

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