import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDarkMode = false;
  bool isAutoDarkMode = false;

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    isAutoDarkMode = prefs.getBool('autoDarkMode') ?? false;
    isDarkMode = isAutoDarkMode ? _getAutoDarkMode() : prefs.getBool('darkMode') ?? false;
    notifyListeners();
  }

  Future<void> savePreferences({bool? darkMode, bool? autoDarkMode}) async {
    final prefs = await SharedPreferences.getInstance();
    if (darkMode != null) await prefs.setBool('darkMode', darkMode);
    if (autoDarkMode != null) await prefs.setBool('autoDarkMode', autoDarkMode);
  }

  void toggleDarkMode(bool value) {
    isDarkMode = value;
    isAutoDarkMode = false;
    savePreferences(darkMode: value, autoDarkMode: false);
    notifyListeners();
  }

  void toggleAutoDarkMode(bool value) {
    isAutoDarkMode = value;
    isDarkMode = value ? _getAutoDarkMode() : isDarkMode;
    savePreferences(autoDarkMode: value, darkMode: isDarkMode);
    notifyListeners();
  }

  bool _getAutoDarkMode() {
    final hour = DateTime.now().hour;
    return (hour >= 18 || hour < 6);
  }
  
  Future<bool> getSwitchState(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  Future<void> setSwitchState(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}
