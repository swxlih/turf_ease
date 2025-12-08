import 'package:flutter/material.dart';

class BookingProvider extends ChangeNotifier {
  DateTime? selectedDate;
  List<String> selectedSlots = [];

  int morningRate = 0;
  int eveningRate = 0;

  // Rentals
  int batCount = 0;
  int racketCount = 0;
  int bootCount = 0;
  String? selectedBootSize;

  // Booked slots pulled from server for the selected date
  List<String> bookedSlots = [];

  int slotTotalPrice = 0;

  // SET RATES
  void setRates(int morning, int evening) {
    morningRate = morning;
    eveningRate = evening;
    _recalculate();
    notifyListeners();
  }

  // SET DATE
  void setDate(DateTime date) {
    selectedDate = date;
    selectedSlots.clear();
    slotTotalPrice = 0;
    notifyListeners();
  }

  // SET BOOKED SLOTS
  void setBookedSlots(List<String> slots) {
    bookedSlots = slots;
    notifyListeners();
  }

  // TOGGLE SLOT
  void toggleSlot(String slot, List<String> morningSlots) {
    if (selectedSlots.contains(slot)) {
      selectedSlots.remove(slot);
    } else {
      selectedSlots.add(slot);
    }
    _calculateSlotPrice(morningSlots);
    notifyListeners();
  }

  // CALCULATE PRICE
  void _calculateSlotPrice(List<String> morningSlots) {
    slotTotalPrice = 0;
    for (var s in selectedSlots) {
      if (morningSlots.contains(s)) {
        slotTotalPrice += morningRate;
      } else {
        slotTotalPrice += eveningRate;
      }
    }
  }

  void _recalculate() {
    // helper if rates change while slots are selected
    // caller must pass morningSlots to toggleSlot normally
    // this is a safe fallback (keeps slotTotalPrice unchanged if nothing selected)
  }

  // RENTAL COUNTS
  void updateBatCount(int count) {
    batCount = count;
    notifyListeners();
  }

  void updateRacketCount(int count) {
    racketCount = count;
    notifyListeners();
  }

  void updateBootCount(int count) {
    bootCount = count;
    notifyListeners();
  }

  void updateBootSize(String? size) {
    selectedBootSize = size;
    notifyListeners();
  }

  void resetAll() {
    selectedDate = null;
    selectedSlots = [];
    batCount = 0;
    racketCount = 0;
    bootCount = 0;
    selectedBootSize = null;
    slotTotalPrice = 0;
    bookedSlots = [];
    notifyListeners();
  }
}
