import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    primaryColor: const Color(0xFF29A165),
    cardColor: const Color(0xFFFFFFFF),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF0E0E0F)),
      bodyMedium: TextStyle(color: Color(0xFF0E0E0F)),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFFFFFFF),
      hintStyle: TextStyle(color: Color(0xFF797A7E)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFFFFFF),
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF29A165),
      secondary: Color(0xFF29A165),
      background: Color(0xFFFAFAFA),
    ),
  );

  ThemeData get darkTheme => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0E0E10), // Already correct
  primaryColor: const Color(0xFF29A165),
  cardColor: const Color(0xFF1C1D1F), // Updated
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF242425), // NEW: AppBar background colour
    iconTheme: IconThemeData(color: Color(0xFFFAFAFA)), // Optional: ensure icons stay visible
    titleTextStyle: TextStyle(color: Color(0xFFFAFAFA), fontSize: 20, fontWeight: FontWeight.w600),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFFAFAFA)),
    bodyMedium: TextStyle(color: Color(0xFFFAFAFA)),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF1C1E1F),
    hintStyle: TextStyle(color: Color(0xFF797A7E)),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFFAFAFA)),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1C1D1F), // Updated
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white,
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF29A165),
    secondary: Color(0xFF29A165),
    background: Color(0xFF0E0E10),
  ),
);

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
