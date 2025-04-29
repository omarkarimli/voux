import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff1565c0), // deep blue
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffbbdefb), // light blue
      onPrimaryContainer: Color(0xff002f6c),
      secondary: Color(0xff5c6bc0), // indigo blue
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffc5cae9),
      onSecondaryContainer: Color(0xff1a237e),
      tertiary: Color(0xff039be5), // sky blue
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffb3e5fc),
      onTertiaryContainer: Color(0xff01579b),
      error: Color(0xffb00020),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff370001),
      surface: Color(0xfff5f5f5),
      onSurface: Color(0xff1a1a1a),
      onSurfaceVariant: Color(0xff44483d),
      outline: Color(0xff757575),
      outlineVariant: Color(0xffc5c8ba),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e2e2e),
      inversePrimary: Color(0xff90caf9),
      surfaceTint: Color(0xff1565c0),
      primaryFixed: Color(0xffbbdefb),
      onPrimaryFixed: Color(0xff002f6c),
      primaryFixedDim: Color(0xff90caf9),
      onPrimaryFixedVariant: Color(0xff003c8f),
      secondaryFixed: Color(0xffc5cae9),
      onSecondaryFixed: Color(0xff1a237e),
      secondaryFixedDim: Color(0xff9fa8da),
      onSecondaryFixedVariant: Color(0xff303f9f),
      tertiaryFixed: Color(0xffb3e5fc),
      onTertiaryFixed: Color(0xff01579b),
      tertiaryFixedDim: Color(0xff81d4fa),
      onTertiaryFixedVariant: Color(0xff0277bd),
      surfaceDim: Color(0xffe0e0e0),
      surfaceBright: Color(0xffffffff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f4f6),
      surfaceContainer: Color(0xffeeeeee),
      surfaceContainerHigh: Color(0xffe0e0e0),
      surfaceContainerHighest: Color(0xffd6d6d6),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff90caf9),
      onPrimary: Color(0xff003c8f),
      primaryContainer: Color(0xff14345a),
      onPrimaryContainer: Color(0xffe3f2fd),
      secondary: Color(0xff9fa8da),
      onSecondary: Color(0xff1a237e),
      secondaryContainer: Color(0xff303f9f),
      onSecondaryContainer: Color(0xffc5cae9),
      tertiary: Color(0xff81d4fa),
      onTertiary: Color(0xff01579b),
      tertiaryContainer: Color(0xff0277bd),
      onTertiaryContainer: Color(0xffb3e5fc),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff121212),
      onSurface: Color(0xffe0e0e0),
      onSurfaceVariant: Color(0xffc5c8ba),
      outline: Color(0xff8f9285),
      outlineVariant: Color(0xff44483d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff5f5f5),
      inversePrimary: Color(0xff1565c0),
      surfaceTint: Color(0xff90caf9),
      primaryFixed: Color(0xffbbdefb),
      onPrimaryFixed: Color(0xff002f6c),
      primaryFixedDim: Color(0xff90caf9),
      onPrimaryFixedVariant: Color(0xff003c8f),
      secondaryFixed: Color(0xffc5cae9),
      onSecondaryFixed: Color(0xff1a237e),
      secondaryFixedDim: Color(0xff9fa8da),
      onSecondaryFixedVariant: Color(0xff303f9f),
      tertiaryFixed: Color(0xffb3e5fc),
      onTertiaryFixed: Color(0xff01579b),
      tertiaryFixedDim: Color(0xff81d4fa),
      onTertiaryFixedVariant: Color(0xff0277bd),
      surfaceDim: Color(0xff1e1e1e),
      surfaceBright: Color(0xff2c2c2c),
      surfaceContainerLowest: Color(0xff0c0c0c),
      surfaceContainerLow: Color(0xff1a1a1a),
      surfaceContainer: Color(0xff1e1e1e),
      surfaceContainerHigh: Color(0xff282828),
      surfaceContainerHighest: Color(0xff333333),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,
  );

  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
