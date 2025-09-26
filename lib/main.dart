import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens.dart';

Future<ThemeMode> _loadInitialThemeMode() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt('theme_mode_v1');
    switch (v) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      case 0:
      default:
        return ThemeMode.system;
    }
  } catch (_) {
    return ThemeMode.system;
  }
}

Future<void> saveThemeModePreference(ThemeMode mode) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final v = mode == ThemeMode.light ? 1 : mode == ThemeMode.dark ? 2 : 0;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    await prefs.setInt('theme_mode_v1_$uid', v);
  } catch (_) {}
}

Future<ThemeMode> loadThemeModeForUid(String uid) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt('theme_mode_v1_$uid');
    switch (v) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  } catch (_) {
    return ThemeMode.system;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
   await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyD9hrt1xgswNVW4xRi4Qn3nhPiLFHBn3H8",
      authDomain: "ruhire.firebaseapp.com",
      projectId: "ruhire",
      storageBucket: "ruhire.firebasestorage.app",
      messagingSenderId: "1043910811642",
      appId: "1:1043910811642:web:d74170dc1df929e2490e43"
    )
  );}
  else{
   await Firebase.initializeApp();
  }
  final initialMode = await _loadInitialThemeMode();
  runApp(ProviderScope(
    overrides: [
      themeModeProvider.overrideWith(() => ThemeModeNotifier(initialMode: initialMode)),
    ],
    child: const MyApp(),
  ));

}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  ThemeModeNotifier({ThemeMode? initialMode}) : _initial = initialMode ?? ThemeMode.system;
  final ThemeMode _initial;
  @override
  ThemeMode build() => _initial;
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  () => ThemeModeNotifier(),
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lightScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF1E88E5), // Blue
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFFFFC107), // Yellow (Accent)
      onSecondary: Color(0xFF212121), // Dark Gray
      error: Color(0xFFE53935), // Red
      onError: Color(0xFFFFFFFF),
      background: Color(0xFFECEFF1), // Light Gray background
      onBackground: Color(0xFF212121), // Dark Gray
      surface: Color(0xFFFFFFFF), // White cards/forms (brighter than background)
      onSurface: Color(0xFF212121), // Dark Gray
    );

    final darkScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF90CAF9), // Light Blue
      onPrimary: Color(0xFF121212),
      secondary: Color(0xFFFFD54F), // Amber
      onSecondary: Color(0xFF121212),
      error: Color(0xFFEF9A9A), // Light Red
      onError: Color(0xFF121212),
      background: Color(0xFF121212), // Dark Gray
      onBackground: Color(0xFFFFFFFF), // White
      surface: Color(0xFF1E1E1E), // Gray
      onSurface: Color(0xFFFFFFFF), // White
    );

    ThemeData themed(ColorScheme scheme) {
      final isDark = scheme.brightness == Brightness.dark;
      return ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.background,
        canvasColor: scheme.background,
        appBarTheme: AppBarTheme(
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: scheme.surface,
          elevation: 1,
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            minimumSize: const Size(48, 44),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: scheme.primary,
            side: BorderSide(color: scheme.primary),
            minimumSize: const Size(48, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: scheme.primary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: isDark ? const Color(0xFF222222) : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: scheme.primary, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          labelStyle: TextStyle(color: scheme.onSurface.withOpacity(0.8)),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: isDark ? const Color(0xFF2A2A2A) : scheme.surface,
          contentTextStyle: TextStyle(color: scheme.onSurface),
          actionTextColor: scheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        dividerTheme: DividerThemeData(
          color: scheme.onSurface.withOpacity(0.12),
          thickness: 1,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: isDark ? const Color(0xFF2A2A2A) : scheme.surface,
          labelStyle: TextStyle(color: scheme.onSurface),
          selectedColor: scheme.secondary.withOpacity(0.2),
          secondarySelectedColor: scheme.primary.withOpacity(0.2),
          side: BorderSide(color: scheme.onSurface.withOpacity(0.12)),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: scheme.surface,
          indicatorColor: scheme.primary.withOpacity(0.12),
          labelTextStyle: WidgetStateProperty.all(TextStyle(color: scheme.onSurface)),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(color: selected ? scheme.primary : scheme.onSurface.withOpacity(0.8));
          }),
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: scheme.surface,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: scheme.surface,
          titleTextStyle: TextStyle(color: scheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
          contentTextStyle: TextStyle(color: scheme.onSurface),
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

    final mode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Ruhire',
      themeMode: mode,
      theme: themed(lightScheme),
      darkTheme: themed(darkScheme),
      debugShowCheckedModeBanner: false,
      home: const RoleGate(),
    );
  }
}

// Removed template counter screen; routing handled by RoleGate
