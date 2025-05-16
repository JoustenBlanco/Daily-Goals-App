import 'package:flutter/material.dart';
import 'package:tasks_list/task_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainState();
}

class _MainState extends State<MainApp> {
  bool _isDarkMode = false;
  bool _isAutoDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    bool auto = prefs.getBool('autoDarkMode') ?? false;
    bool dark = prefs.getBool('darkMode') ?? false;
    setState(() {
      _isAutoDarkMode = auto;
      _isDarkMode = auto ? _getAutoDarkMode() : dark;
    });
  }

  Future<void> _savePreferences({bool? darkMode, bool? autoDarkMode}) async {
    final prefs = await SharedPreferences.getInstance();
    if (darkMode != null) prefs.setBool('darkMode', darkMode);
    if (autoDarkMode != null) prefs.setBool('autoDarkMode', autoDarkMode);
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
      _isAutoDarkMode = false;
    });
    _savePreferences(darkMode: value, autoDarkMode: false);
  }

  void _toggleAutoDarkMode(bool value) {
    setState(() {
      _isAutoDarkMode = value;
      _isDarkMode = value ? _getAutoDarkMode() : _isDarkMode;
    });
    _savePreferences(autoDarkMode: value);
    if (value) {
      setState(() {
        _isDarkMode = _getAutoDarkMode();
      });
    }
  }

  bool _getAutoDarkMode() {
    final hour = DateTime.now().hour;
    return (hour >= 18 || hour < 6);
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Settings(
          isDarkMode: _isDarkMode,
          isAutoDarkMode: _isAutoDarkMode,
          onThemeChanged: _toggleDarkMode,
          onAutoThemeChanged: _toggleAutoDarkMode,
        ),
      ),
    );
    await _loadPreferences();
  }

  Future<bool> getSwitchState(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  Future<void> setSwitchState(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tareas',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode
          ? ThemeData.dark().copyWith(
              useMaterial3: true,
              colorScheme: ColorScheme(
                brightness: Brightness.dark,
                primary: Color(0xFF2196F3),
                onPrimary: Colors.white,
                secondary: Color(0xFF4CAF50),
                onSecondary: Colors.white,
                error: Color(0xFFFF5252),
                onError: Colors.white,
                background: Color(0xFF181C20),
                onBackground: Colors.white,
                surface: Color(0xFF23272F),
                onSurface: Colors.white,
              ),
              scaffoldBackgroundColor: Color(0xFF181C20),
              appBarTheme: AppBarTheme(
                backgroundColor: Color(0xFF23272F),
                foregroundColor: Colors.white,
              ),
            )
          : ThemeData.light().copyWith(
              useMaterial3: true,
              colorScheme: ColorScheme(
                brightness: Brightness.light,
                primary: Color(0xFF1976D2),
                onPrimary: Colors.white,
                secondary: Color(0xFF43A047),
                onSecondary: Colors.white,
                error: Color(0xFFD32F2F),
                onError: Colors.white,
                background: Color(0xFFF5F7FA),
                onBackground: Color(0xFF23272F),
                surface: Colors.white,
                onSurface: Color(0xFF23272F),
              ),
              scaffoldBackgroundColor: Color(0xFFF5F7FA),
              appBarTheme: AppBarTheme(
                backgroundColor: Color(0xFF1976D2),
                foregroundColor: Colors.white,
              ),
            ),
      home: TaskListPage(
        isDarkMode: _isDarkMode,
        isAutoDarkMode: _isAutoDarkMode,
        onThemeChanged: _toggleDarkMode,
        onAutoThemeChanged: _toggleAutoDarkMode,
        onOpenSettings: _openSettings,
      ),
    );
  }
}