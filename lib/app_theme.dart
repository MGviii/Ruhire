import 'package:flutter/material.dart';

// Centralized app theming

const ColorScheme lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF1E88E5),
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFFFFC107),
  onSecondary: Color(0xFF212121),
  error: Color(0xFFE53935),
  onError: Color(0xFFFFFFFF),
  background: Color(0xFFECEFF1),
  onBackground: Color(0xFF212121),
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF212121),
);

const ColorScheme darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF90CAF9),
  onPrimary: Color(0xFF0D47A1),
  secondary: Color(0xFFFFD54F),
  onSecondary: Color(0xFF212121),
  error: Color(0xFFEF9A9A),
  onError: Color(0xFF1B1B1B),
  background: Color(0xFF121212),
  onBackground: Color(0xFFE0E0E0),
  surface: Color(0xFF1E1E1E),
  onSurface: Color(0xFFE0E0E0),
);

ThemeData themed(ColorScheme scheme) {
  final isDark = scheme.brightness == Brightness.dark;
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: scheme.background,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surface,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.onSurface.withOpacity(0.06)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary.withOpacity(0.8)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? const Color(0xFF2D2D2D) : scheme.surface,
      contentTextStyle: TextStyle(color: scheme.onSurface),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: DividerThemeData(color: scheme.onSurface.withOpacity(0.12), thickness: 1),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.primary.withOpacity(0.12),
      labelStyle: TextStyle(color: scheme.onSurface),
      shape: StadiumBorder(side: BorderSide(color: scheme.primary.withOpacity(0.24))),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: scheme.primary.withOpacity(0.12),
      surfaceTintColor: Colors.transparent,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : scheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: TextStyle(color: scheme.onSurface),
    ),
  );
}
