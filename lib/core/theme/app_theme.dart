import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColorTheme {
  final String name;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Brightness brightness;

  const AppColorTheme({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    this.brightness = Brightness.light,
  });

  ThemeData toThemeData() {
    final colorScheme = brightness == Brightness.light
        ? ColorScheme.light(
            primary: primary,
            secondary: secondary,
            surface: surface,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: const Color(0xFF1A1A2E),
          )
        : ColorScheme.dark(
            primary: primary,
            secondary: secondary,
            surface: surface,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: const Color(0xFFE2E8F0),
          );

    final bgColor = brightness == Brightness.light ? background : surface;
    final cardColor = brightness == Brightness.light ? surface : const Color(0xFF1E293B);
    final scaffoldBg = brightness == Brightness.light ? background : const Color(0xFF0B1220);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
        shadowColor: primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: accent.withOpacity(0.3),
        labelStyle: GoogleFonts.poppins(color: primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        elevation: 8,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade100,
        thickness: 1,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
        bodySmall: TextStyle(fontSize: 12),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontSize: 11),
      )),
    );
  }
}

final defaultTealTheme = AppColorTheme(
  name: 'Teal',
  primary: const Color(0xFF06B6C8),
  secondary: const Color(0xFF0F4C5C),
  accent: const Color(0xFFB6F2EF),
  background: const Color(0xFFF8FAFC),
  surface: const Color(0xFFFFFFFF),
);

final oceanTheme = AppColorTheme(
  name: 'Ocean',
  primary: const Color(0xFF2563EB),
  secondary: const Color(0xFF0EA5E9),
  accent: const Color(0xFFDBEAFE),
  background: const Color(0xFFF8FBFF),
  surface: const Color(0xFFFFFFFF),
);

final sunsetTheme = AppColorTheme(
  name: 'Sunset',
  primary: const Color(0xFFF97316),
  secondary: const Color(0xFFFB7185),
  accent: const Color(0xFFFFE4D6),
  background: const Color(0xFFFFF8F4),
  surface: const Color(0xFFFFFFFF),
);

final lavenderTheme = AppColorTheme(
  name: 'Lavender',
  primary: const Color(0xFF8B5CF6),
  secondary: const Color(0xFFA855F7),
  accent: const Color(0xFFE9D5FF),
  background: const Color(0xFFFAF7FF),
  surface: const Color(0xFFFFFFFF),
);

final emeraldTheme = AppColorTheme(
  name: 'Emerald',
  primary: const Color(0xFF10B981),
  secondary: const Color(0xFF059669),
  accent: const Color(0xFFD1FAE5),
  background: const Color(0xFFF6FFFB),
  surface: const Color(0xFFFFFFFF),
);

final darkTheme = AppColorTheme(
  name: 'Dark',
  primary: const Color(0xFF22D3EE),
  secondary: const Color(0xFF60A5FA),
  accent: const Color(0xFF155E75),
  background: const Color(0xFF0B1220),
  surface: const Color(0xFF121A2A),
  brightness: Brightness.dark,
);

final allThemes = [
  defaultTealTheme,
  oceanTheme,
  sunsetTheme,
  lavenderTheme,
  emeraldTheme,
  darkTheme,
];
