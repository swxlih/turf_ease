import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> fetchUserData(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      if (userDoc.exists) {
        _userId = uid;
        _username = userDoc.data()?['name'] ?? '';
        _phoneNumber = userDoc.data()?['number'] ?? '';
        notifyListeners();
        print("✅ UserProvider populated for $uid");
      }
    } catch (e) {
      print("❌ Error fetching user data for provider: $e");
    }
  }

  void clearUser() {
    _userId = '';
    _username = '';
    _phoneNumber = '';
    notifyListeners();
  }
}
