import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:voux/utils/translation_cache.dart';

import '../di/locator.dart';
import 'constants.dart';

extension StringExtensions on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

extension TruncateExtension on String {
  String truncateWithEllipsis(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
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
          elevation: 3,
          showCloseIcon: true,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Constants.cornerRadiusSmall),
          ),
          content: Text(
            message,
            style: Theme.of(this).textTheme.bodyMedium?.copyWith(
              color: state == Constants.success
                  ? Theme.of(this).colorScheme.surface
                  : Theme.of(this).colorScheme.onErrorContainer,
            ),
          ),
          backgroundColor: state == Constants.success
              ? Theme.of(this).colorScheme.onSurface
              : Theme.of(this).colorScheme.errorContainer,
          closeIconColor: state == Constants.success
              ? Theme.of(this).colorScheme.surface
              : Theme.of(this).colorScheme.onErrorContainer,
        ),
      );
    });

    if (kDebugMode) {
      print(state == Constants.success
          ? "Success: $message"
          : "Error: $message"
      );
    }
  }
}

extension StyledTextExtension on String {
  List<TextSpan> toStyledTextSpans(TextStyle baseStyle) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'(\*\*\*[^*]+\*\*\*|\*\*[^*]+\*\*|\*[^*]+\*)'); // bold italic, bold, italic
    int currentIndex = 0;

    for (final match in regex.allMatches(this)) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: substring(currentIndex, match.start),
          style: baseStyle,
        ));
      }

      final matchText = match.group(0)!;

      if (matchText.startsWith('***')) {
        spans.add(TextSpan(
          text: matchText.substring(3, matchText.length - 3),
          style: baseStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic
          ),
        ));
      } else if (matchText.startsWith('**')) {
        spans.add(TextSpan(
          text: matchText.substring(2, matchText.length - 2),
          style: baseStyle.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ));
      } else if (matchText.startsWith('*')) {
        spans.add(TextSpan(
          text: matchText.substring(1, matchText.length - 1),
          style: baseStyle.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ));
      }

      currentIndex = match.end;
    }

    if (currentIndex < length) {
      spans.add(TextSpan(
        text: substring(currentIndex),
        style: baseStyle,
      ));
    }

    return spans;
  }
}

extension PriceFormatting on String {
  String toFormattedPrice() {
    // Check if the string contains a decimal point
    if (contains('.') && split('.')[1] == '00') {
      // If the decimal part is .00, remove it
      return "\$${split('.')[0]}";
    } else {
      // Otherwise, keep the original string
      return "\$$this";
    }
  }
}

extension TranslationExtension on String {
  Widget translatedText(
      BuildContext context, {
        required String localeLanguageCode,
        TextStyle? style,
      }) {
    // Access services via locator
    final translationCache = locator<TranslationCache>();
    final translator = locator<GoogleTranslator>();

    if (localeLanguageCode == "en") {
      return SelectableText(this, style: style);
    }

    // Check cache first
    final cachedTranslation = translationCache.get(this, localeLanguageCode);
    if (cachedTranslation != null) {
      return SelectableText(cachedTranslation, style: style);
    }

    // If not in cache, fetch and cache
    return FutureBuilder<Translation>(
      future: translator.translate(this, from: 'en', to: localeLanguageCode),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Cache the new translation
          translationCache.set(this, localeLanguageCode, snapshot.data!.text);
          return SelectableText(snapshot.data!.text, style: style);
        }
        // Fallback to original text while loading or on error
        return SelectableText(this, style: style);
      },
    );
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
