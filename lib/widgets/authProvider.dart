import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool isAuthenticated = false;

  void setAuthentication(bool status) {
    isAuthenticated = status;
    notifyListeners();
  }
}
