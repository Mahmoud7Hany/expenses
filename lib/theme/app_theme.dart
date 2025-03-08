// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _isInitialized = false;
  late final SharedPreferences _prefs;
  
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  Future<void> initializeTheme() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  ThemeData get themeData {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  static final _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue[700],
    scaffoldBackgroundColor: Colors.grey[50],
    cardColor: Colors.white,
    shadowColor: Colors.grey.withOpacity(0.2),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue[700],
      elevation: 4,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
      titleMedium: TextStyle(color: Colors.black87),
    ),
  );

  static final _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blue[400],
    scaffoldBackgroundColor: Color(0xFF1A1A1A),
    cardColor: Color(0xFF2D2D2D),
    shadowColor: Colors.black.withOpacity(0.3),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF2D2D2D),
      elevation: 4,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
    ),
  );

  Color get cardGradientStart => _isDarkMode ? Color(0xFF3D3D3D) : Colors.blue[800]!;
  Color get cardGradientMiddle => _isDarkMode ? Color(0xFF353535) : Colors.blue[600]!;
  Color get cardGradientEnd => _isDarkMode ? Color(0xFF2D2D2D) : Colors.blue[400]!;
}
