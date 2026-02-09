import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Definition of a Theme Palette
class ThemePalette {
  final String id;
  final String name;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color surface;
  final Color background;
  final Color textMain;

  const ThemePalette({
    required this.id,
    required this.name,
    required this.primary,
    required this.secondary,
    required this.accent,
    this.surface = Colors.white,
    this.background = const Color(0xFFFCF7F3), // Slightly more neutral
    this.textMain = const Color(0xFF1A1A1A), // Near black for high contrast
  });

  LinearGradient get gradient => LinearGradient(
    // Single tone gradient: Primary -> Slightly Lighter Primary
    colors: [primary, Color.lerp(primary, Colors.white, 0.2)!],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppGradientExtension extends ThemeExtension<AppGradientExtension> {
  final LinearGradient gradient;
  final LinearGradient surfaceGradient;

  const AppGradientExtension({
    required this.gradient,
    required this.surfaceGradient,
  });

  @override
  ThemeExtension<AppGradientExtension> copyWith({
    LinearGradient? gradient,
    LinearGradient? surfaceGradient,
  }) {
    return AppGradientExtension(
      gradient: gradient ?? this.gradient,
      surfaceGradient: surfaceGradient ?? this.surfaceGradient,
    );
  }

  @override
  ThemeExtension<AppGradientExtension> lerp(
    ThemeExtension<AppGradientExtension>? other,
    double t,
  ) {
    if (other is! AppGradientExtension) return this;
    return AppGradientExtension(
      gradient: LinearGradient.lerp(gradient, other.gradient, t)!,
      surfaceGradient: LinearGradient.lerp(
        surfaceGradient,
        other.surfaceGradient,
        t,
      )!,
    );
  }
}

class AppPalettes {
  static const defaultTheme = 'cotton_candy';

  static final Map<String, ThemePalette> palettes = {
    'cotton_candy': const ThemePalette(
      id: 'cotton_candy',
      name: 'Pink',
      primary: Color(0xFFFF858F), // More saturated pink
      secondary: Color(0xFF6AB7E2), // More saturated blue
      accent: Color(0xFFFF4D4D),
    ),
    'sky_dreams': const ThemePalette(
      id: 'sky_dreams',
      name: 'Blue',
      primary: Color(0xFF4FACFE), // Stronger Blue
      secondary: Color(0xFF00F2FE),
      accent: Color(0xFFF9D423),
    ),
    'minty_fresh': const ThemePalette(
      id: 'minty_fresh',
      name: 'Mint',
      primary: Color(0xFF2ECC71), // Vibrant Green
      secondary: Color(0xFF27AE60),
      accent: Color(0xFFE67E22),
      background: Color(0xFFF0FAF4),
    ),
    'lavender_haze': const ThemePalette(
      id: 'lavender_haze',
      name: 'Lavender',
      primary: Color(0xFFDCD0FF), // Lavender
      secondary: Color(0xFFE6DFFF), // Lighter Lavender
      accent: Color(0xFF9575CD),
      background: Color(0xFFF6F4FA),
    ),
    'peachy_keen': const ThemePalette(
      id: 'peachy_keen',
      name: 'Peach',
      primary: Color(0xFFFF9A8B), // Vibrant Peach
      secondary: Color(0xFFFF6A88),
      accent: Color(0xFFFF99AC),
      background: Color(0xFFFFFDFB),
    ),
    'glacial_blue': const ThemePalette(
      id: 'glacial_blue',
      name: 'Ice',
      primary: Color(0xFFB0E0E6), // Powder Blue
      secondary: Color(0xFFE0FFFF), // Light Cyan
      accent: Color(0xFF00BFFF),
      background: Color(0xFFF0F8FF),
    ),
    'dreamy_aurora': const ThemePalette(
      id: 'dreamy_aurora',
      name: 'Aurora',
      primary: Color(0xFF7B61FF), // Deep Purple
      secondary: Color(0xFF00D1FF), // Cyan
      accent: Color(0xFFFF00C7), // Magenta
      background: Color(0xFF0F172A), // Dark Slate
      surface: Color(0xFF1E293B),
      textMain: Colors.white,
    ),
    'sunset_magic': const ThemePalette(
      id: 'sunset_magic',
      name: 'Sunset',
      primary: Color(0xFFFF5F6D),
      secondary: Color(0xFFFFC371),
      accent: Color(0xFF8E2DE2),
      background: Color(0xFFFFF5F5),
    ),
  };
}

class AppTheme {
  static ThemeData getTheme(String paletteId) {
    final palette =
        AppPalettes.palettes[paletteId] ??
        AppPalettes.palettes[AppPalettes.defaultTheme]!;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: palette.background,
      primaryColor: palette.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        primary: palette.primary,
        secondary: palette.secondary,
        surface: palette.surface,
        onSurface: palette.textMain,
        background: palette.background,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: palette.textMain,
        displayColor: palette.textMain,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.textMain),
        titleTextStyle: GoogleFonts.varelaRound(
          color: palette.textMain,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadowColor: palette.primary.withOpacity(0.1),
      ),
      extensions: [
        AppGradientExtension(
          gradient: palette.gradient,
          surfaceGradient: LinearGradient(
            colors: [
              palette.primary.withOpacity(0.15),
              // Fade to even lighter primary, not secondary
              palette.primary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ],
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          textStyle: GoogleFonts.varelaRound(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Keeping AppColors for legacy references, but mapped to the palettes where possible or just neutral
class AppColors {
  // Neutral
  static const Color textMain = Color(0xFF1A1A1A); // High contrast
  static const Color textSub = Color(0xFF555555); // Darker sub text
  static const Color white = Colors.white;
  // These are now handled by the palette system but kept for backward compatibility if needed
  static const Color background = Color(0xFFFFF9F5);
  static const Color malePrimary = Color(0xFF89CFF0);
  static const Color femalePrimary = Color(0xFFFFB7B2);
  static const Color femaleAccent = Color(0xFFFF6961);
  static const Color femaleSecondary = Color(0xFFFFDAC1);
}
