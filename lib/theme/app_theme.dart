import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const bg = Color(0xFF0A1226);
  static const surface = Color(0xFF111C36);
  static const surface2 = Color(0xFF16244A);
  static const border = Color(0xFF243664);
  static const text = Color(0xFFE6ECFA);
  static const muted = Color(0xFF8A9AC0);
  static const red = Color(0xFFFF3B4E);
  static const green = Color(0xFF22C55E);
  static const orange = Color(0xFFFFA726);
  static const gray = Color(0xFF7B879F);
  static const accent = Color(0xFF3B82F6);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: C.accent,
      brightness: Brightness.dark,
      surface: C.surface,
    ),
    scaffoldBackgroundColor: C.bg,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: GoogleFonts.inter().fontFamily,
      bodyColor: C.text,
      displayColor: C.text,
    ),
    cardTheme: CardThemeData(
      color: C.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: C.border),
      ),
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: C.surface),
    dividerColor: C.border,
  );
}
