import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String THEME_KEY = 'tema_oscuro';

  // Tema Claro (normal, accesible)
  static ThemeData temaClaro = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFF1976D2), // Azul suave
    scaffoldBackgroundColor: Color(0xFFF5F5F5),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1976D2),
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    cardTheme: CardThemeData(
      color: Color(0xFFFFFFFF),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF1976D2),
      secondary: Color(0xFFFFB74D),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF202124),
      background: Color(0xFFF5F5F5),
      onBackground: Color(0xFF202124),
    ),
  );

  // Tema Oscuro (moderno y fácil de ver)
  static ThemeData temaOscuro = ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    primaryColor: Color(0xFF1565C0), // Azul oscuro
    scaffoldBackgroundColor: Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1565C0),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    cardTheme: CardThemeData(
      color: Color(0xFF232323),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF1565C0),
      secondary: Color(0xFFFF9800),
      surface: Color(0xFF232323),
      onSurface: Colors.white,
      background: Color(0xFF121212),
      onBackground: Colors.white,
    ),
  );

  static Future<void> guardarTema(bool esOscuro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(THEME_KEY, esOscuro);
  }

  static Future<bool> obtenerTema() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_KEY) ?? false;
  }
}
