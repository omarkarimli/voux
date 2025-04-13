import 'package:flutter/material.dart';

import 'constants.dart';

extension StringExtensions on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

extension TextFormatter on String {
  String chunkText(int length) {
    List<String> words = trim().split(RegExp(r'\s+'));
    List<String> lines = [];
    String currentLine = "";

    for (String word in words) {
      if ((currentLine + word).length <= length) {
        currentLine += (currentLine.isEmpty ? "" : " ") + word;
      } else {
        lines.add(currentLine); // Save the current line
        currentLine = word; // Start a new line with the current word
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine); // Add the last line if any
    }

    return lines.join("\n"); // Join lines with line breaks
  }
}

extension FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension SnackBarHelper on BuildContext {
  void showCustomSnackBar(String state, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: Theme.of(this).textTheme.bodyMedium?.copyWith(
              color: state == Constants.success
                  ? Theme.of(this).colorScheme.onPrimaryContainer
                  : Theme.of(this).colorScheme.onErrorContainer,
            ),
          ),
          backgroundColor: state == Constants.success
              ? Theme.of(this).colorScheme.primaryContainer
              : Theme.of(this).colorScheme.errorContainer,
          closeIconColor: state == Constants.success
              ? Theme.of(this).colorScheme.onPrimaryContainer
              : Theme.of(this).colorScheme.onErrorContainer,
          showCloseIcon: true,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });

    print(state == Constants.success
        ? "Success: $message"
        : "Error: $message"
    );
  }
}

extension PriceFormatting on String {
  String toFormattedPrice() {
    // Check if the string contains a decimal point
    if (this.contains('.') && this.split('.')[1] == '00') {
      // If the decimal part is .00, remove it
      return "\$${this.split('.')[0]}";
    } else {
      // Otherwise, keep the original string
      return "\$${this}";
    }
  }
}

extension HexColor on String {
  Color toColor() {
    final hex = replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

extension ColorExtension on Color {
  bool get isDark {
    // Use luminance to determine brightness
    return computeLuminance() < 0.5;
  }
}
