import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/Features/UserApp/provider/booking_provider.dart';
import 'package:provider/provider.dart';

Future<void> fetchBookedSlotsByDate(
    String turfId, DateTime selectedDate, BuildContext context) async {
  try {
    print("🚀 Fetching booked slots for $turfId on $selectedDate");

    // Convert selected date into start & end of the day
    final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Fetch only bookings for that turf and that date range
    final bookingsSnapshot = await FirebaseFirestore.instance
        .collection("turfbookings")
        .doc(turfId)
        .collection("bookings")
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    print("📦 Found ${bookingsSnapshot.docs.length} booking documents for this date");

    List<String> allSlots = [];

    for (var doc in bookingsSnapshot.docs) {
      List<dynamic> slots = doc['slots'] ?? [];
      for (var slotData in slots) {
        if (slotData is Map && slotData.containsKey('slot')) {
          allSlots.add(slotData['slot']);
        }
      }
    }

    print("✅ Combined slots for $selectedDate: $allSlots");

    Provider.of<BookingProvider>(context, listen: false).setBookedSlots(allSlots);
  } catch (e) {
    print("❌ Error fetching booked slots by date: $e");
  }
}
