import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _currentSessionString;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  List<String> _savedSessions = [];
  List<String> get savedSessions => _savedSessions;

  AuthProvider() {
    loadSavedSessions();
  }

  Future<void> checkAuthentication() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null){
      _userId = session.user.id;
      _isAuthenticated = true;
      _currentSessionString = jsonEncode(session.toJson());
      await _saveSessionString(_currentSessionString!);
    }else{
      _userId = null;
      _isAuthenticated = false;
      _currentSessionString = null;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = false;
    _userId = null;
    _currentSessionString = null;
    _savedSessions = [];
    await prefs.setStringList('sessions', _savedSessions);
    notifyListeners();
  }

  Future<void> deleteSession(String sessionString) async {
    final prefs = await SharedPreferences.getInstance();
    _savedSessions.removeWhere((s){ 
      Map<String, dynamic> sessionData = jsonDecode(s);
      Map<String, dynamic> currentSessionData = jsonDecode(sessionString);
      return sessionData['user']?['email'] == currentSessionData['user']?['email'];
    });
    await prefs.setStringList('sessions', _savedSessions);
  }

  Future<void> _saveSessionString(String sessionString) async {
    final prefs = await SharedPreferences.getInstance();

    final index = _savedSessions.indexWhere((s){ 
      Map<String, dynamic> sessionData = jsonDecode(s);
      Map<String, dynamic> currentSessionData = jsonDecode(sessionString);
      return sessionData['user']?['email'] == currentSessionData['user']?['email'];
    });
    if (index != -1) {
      _savedSessions[index] = sessionString; 
    } else {
      _savedSessions.add(sessionString);
    }

    await prefs.setStringList('sessions', _savedSessions);
  }

  Future<void> loadSavedSessions() async {
    final prefs = await SharedPreferences.getInstance();
    _savedSessions = prefs.getStringList('sessions') ?? [];
    print('Sesiones cargadas: $_savedSessions');
    notifyListeners();
  }

  Future<void> switchToSession(String sessionString) async {
    final client = Supabase.instance.client;
    await client.auth.recoverSession(sessionString);
    await checkAuthentication();
  }
}
