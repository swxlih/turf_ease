import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TurfDetailController extends ChangeNotifier {
  String ownerName = "";
  String ownerNumber = "";
  Map<String, bool> features = {};
  List<Map<String, dynamic>> reviews = [];

  bool isLoading = true;

  /// Load all required data
  Future<void> loadTurfDetails(String ownerUid) async {
    try {
      await Future.wait([
        _fetchOwnerDetails(ownerUid),
        _fetchReviews(ownerUid),
      ]);
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch owner name, number, and features
  Future<void> _fetchOwnerDetails(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data();
      final featureData = data?['features'] ?? {};

      ownerName = data?['name'] ?? 'Unknown Owner';
      ownerNumber = data?['number'] ?? '';

      features = {
        "Bathroom": featureData['bathroom'] ?? false,
        "Rest Area": featureData['restArea'] ?? false,
        "Parking": featureData['parking'] ?? false,
        "Shower": featureData['shower'] ?? false,
      };
    }
  }

  /// Fetch reviews for that turf
  Future<void> _fetchReviews(String uid) async {
    final snap = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('reviews')
        .get();

    reviews = snap.docs.map((doc) {
      return {
        "comment": doc['comment'] ?? '',
        "rating": doc['rating'] ?? 0,
        "userid": doc['userid'] ?? '',
        "username": doc['username'] ?? '',
      };
    }).toList();
  }
}
