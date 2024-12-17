import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Color get textColor =>
      _isDarkMode ? Colors.white : Color.fromARGB(255, 45, 49, 73);

  Color get Container => _isDarkMode
      ? Color.fromARGB(164, 53, 56, 99)
      : Color.fromARGB(226, 30, 31, 56);

  ThemeData get currentTheme {
    return _isDarkMode
        ? ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.black,
          )
        : ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.white,
          );
  }
}
