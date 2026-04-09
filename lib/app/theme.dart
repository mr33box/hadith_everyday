import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ─── Brand Colours ────────────────────────────────────────────────────────

  static const Color _gold = Color(0xFFD4AF37);
  static const Color _warmBrown = Color(0xFF8B5E3C);
  static const Color _deepNavy = Color(0xFF0F3460);
  static const Color _darkBg = Color(0xFF121420);
  static const Color _darkSurface = Color(0xFF1E2235);
  static const Color _darkCard = Color(0xFF252A3D);
  static const Color _lightBg = Color(0xFFFFF8EE);
  static const Color _lightSurface = Color(0xFFFFF3DC);
  static const Color _lightCard = Color(0xFFFFFFFF);

  // ─── Light Theme ──────────────────────────────────────────────────────────

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: _lightBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _warmBrown,
        brightness: Brightness.light,
        background: _lightBg,
        surface: _lightSurface,
        primary: _warmBrown,
        secondary: _gold,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
      ),
      textTheme: _textTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: _lightBg,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _warmBrown),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _warmBrown,
        ),
      ),
      cardTheme: CardThemeData(
        color: _lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _warmBrown.withOpacity(0.1)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _warmBrown,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.cairo(
              fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected) ? _warmBrown : Colors.grey),
        trackColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected)
                ? _warmBrown.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE8D8C0), thickness: 1),
      extensions: const [AppColors.light],
    );
  }

  // ─── Dark Theme ───────────────────────────────────────────────────────────

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: _darkBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _gold,
        brightness: Brightness.dark,
        background: _darkBg,
        surface: _darkSurface,
        primary: _gold,
        secondary: _warmBrown,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
      ),
      textTheme: _textTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkBg,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _gold),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _gold,
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _gold.withOpacity(0.12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _gold,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.cairo(
              fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected) ? _gold : Colors.grey),
        trackColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected)
                ? _gold.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF2A2F45), thickness: 1),
      extensions: const [AppColors.dark],
    );
  }

  // ─── Text Theme ───────────────────────────────────────────────────────────

  static TextTheme _textTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : const Color(0xFF1A0E00);
    final subColor = isDark ? Colors.white70 : Colors.black54;

    return TextTheme(
      displayLarge: GoogleFonts.cairo(
          fontSize: 32, fontWeight: FontWeight.w800, color: baseColor),
      displayMedium: GoogleFonts.cairo(
          fontSize: 28, fontWeight: FontWeight.w700, color: baseColor),
      headlineLarge: GoogleFonts.cairo(
          fontSize: 24, fontWeight: FontWeight.w700, color: baseColor),
      headlineMedium: GoogleFonts.cairo(
          fontSize: 20, fontWeight: FontWeight.w600, color: baseColor),
      titleLarge: GoogleFonts.cairo(
          fontSize: 18, fontWeight: FontWeight.w600, color: baseColor),
      titleMedium: GoogleFonts.cairo(
          fontSize: 16, fontWeight: FontWeight.w500, color: baseColor),
      bodyLarge: GoogleFonts.cairo(
          fontSize: 15, fontWeight: FontWeight.w400, color: baseColor),
      bodyMedium: GoogleFonts.cairo(
          fontSize: 14, fontWeight: FontWeight.w400, color: subColor),
      labelLarge: GoogleFonts.cairo(
          fontSize: 13, fontWeight: FontWeight.w600, color: baseColor),
    );
  }
}

// ─── Custom Theme Extension ────────────────────────────────────────────────────

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.gold,
    required this.cardBorder,
    required this.shimmer,
    required this.tagBg,
  });

  final Color gold;
  final Color cardBorder;
  final Color shimmer;
  final Color tagBg;

  static const AppColors light = AppColors(
    gold: Color(0xFF8B6914),
    cardBorder: Color(0xFFE8D8C0),
    shimmer: Color(0xFFF0E0C0),
    tagBg: Color(0xFFFFF3DC),
  );

  static const AppColors dark = AppColors(
    gold: Color(0xFFD4AF37),
    cardBorder: Color(0xFF2A2F45),
    shimmer: Color(0xFF2A2F45),
    tagBg: Color(0xFF252A3D),
  );

  @override
  AppColors copyWith({Color? gold, Color? cardBorder, Color? shimmer, Color? tagBg}) {
    return AppColors(
      gold: gold ?? this.gold,
      cardBorder: cardBorder ?? this.cardBorder,
      shimmer: shimmer ?? this.shimmer,
      tagBg: tagBg ?? this.tagBg,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      gold: Color.lerp(gold, other.gold, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      shimmer: Color.lerp(shimmer, other.shimmer, t)!,
      tagBg: Color.lerp(tagBg, other.tagBg, t)!,
    );
  }
}
