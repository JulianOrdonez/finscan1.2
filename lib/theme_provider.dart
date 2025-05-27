import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider({bool isDarkMode = false})
      : _themeData = isDarkMode ? _darkTheme : _lightTheme;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == _darkTheme;

  void toggleTheme() {
    _themeData = _themeData == _lightTheme ? _darkTheme : _lightTheme;
    notifyListeners();
  }

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      primaryContainer: Color(0xFF64B5F6),
      secondary: Colors.orange,
      background: Colors.white,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.black,
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      color: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 4.0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
    ),
    cardColor: Colors.white,
    unselectedWidgetColor: Colors.grey,
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blueGrey,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF90CAF9),          // Light Blue for primary
      primaryContainer: Color(0xFF1A237E), // Deep Indigo for container
      secondary: Color(0xFFFFB74D),        // Orange accent
      background: Color(0xFF121212),       // Dark background
      surface: Color(0xFF1E1E1E),          // Darker surface
      onPrimary: Colors.black,             // Text/icon on light primary
      onSecondary: Colors.black,
      onBackground: Colors.white,
      onSurface: Colors.white,
      error: Color(0xFFEF5350),
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      color: Color(0xFF1F1F1F),
      foregroundColor: Colors.white,
      elevation: 4.0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFF7043),
      foregroundColor: Colors.white,
    ),
    cardColor: const Color(0xFF1E1E1E),
    unselectedWidgetColor: Colors.grey,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      titleMedium: TextStyle(color: Colors.white),
    ),
    iconTheme: const IconThemeData(color: Colors.white70),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2C2C2C),
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF90CAF9)),
      ),
      hintStyle: TextStyle(color: Colors.white54),
      labelStyle: TextStyle(color: Colors.white),
    ),
  );
}
