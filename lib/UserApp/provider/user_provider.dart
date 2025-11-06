import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _userId = '';
  String _username = '';
  String _phoneNumber = '';

  String get userId => _userId;
  String get username => _username;
  String get phoneNumber => _phoneNumber;

  void setUser({
    required String userId,
    required String username,
    required String phoneNumber,
  }) {
    _userId = userId;
    _username = username;
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  void clearUser() {
    _userId = '';
    _username = '';
    _phoneNumber = '';
    notifyListeners();
  }
}
