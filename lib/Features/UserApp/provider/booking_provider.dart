import 'package:flutter/material.dart';

class BookingProvider with ChangeNotifier {
  final List<String> _bookedSlots = [];

  List<String> get bookedSlots => _bookedSlots;

  void setBookedSlots(List<String> slots) {
    _bookedSlots
      ..clear()
      ..addAll(slots);
    notifyListeners();
  }

  void addSlot(String slot) {
    if (!_bookedSlots.contains(slot)) {
      _bookedSlots.add(slot);
      notifyListeners();
    }
  }

  void removeSlot(String slot) {
    _bookedSlots.remove(slot);
    notifyListeners();
  }

  void clearSlots() {
    _bookedSlots.clear();
    notifyListeners();
  }
}
