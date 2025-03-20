import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme createTextTheme(BuildContext context, String bodyFontString, String displayFontString) {
  TextTheme baseTextTheme = Theme.of(context).textTheme;
  TextTheme bodyTextTheme = GoogleFonts.getTextTheme(bodyFontString, baseTextTheme);
  TextTheme displayTextTheme = GoogleFonts.getTextTheme(displayFontString, baseTextTheme);

  TextTheme textTheme = displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,

    titleLarge: bodyTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
    titleMedium: bodyTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
    titleSmall: bodyTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),

    headlineLarge: bodyTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
    headlineMedium: bodyTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
    headlineSmall: bodyTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
  );
  return textTheme;
}
