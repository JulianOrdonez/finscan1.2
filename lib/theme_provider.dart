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
      primaryContainer: Color(0xFF64B5F6), // Light blue
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
    unselectedWidgetColor: Colors.grey[600],
    // Add other theme properties as needed
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blueGrey,
    colorScheme: const ColorScheme.dark(
      primary: Colors.blueGrey,
      primaryContainer: Color(0xFF78909C), // Dark blue grey
      secondary: Colors.deepOrange,
      background: Color(0xFF121212), // Almost black
      surface: Color(0xFF1E1E1E), // Dark grey
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
      error: Colors.redAccent,
      onError: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      color: Colors.blueGrey,
      foregroundColor: Colors.white,
      elevation: 4.0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.deepOrangeAccent,
      foregroundColor: Colors.white,
    ),
    cardColor: Color(0xFF212121), // Darker grey for cards
    unselectedWidgetColor: Colors.grey[400],
    // Add other theme properties as needed
  );

}