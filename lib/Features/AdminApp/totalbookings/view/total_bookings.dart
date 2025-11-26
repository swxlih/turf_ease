import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TotalBookings extends StatefulWidget {
  const TotalBookings({super.key});

  @override
  State<TotalBookings> createState() => _TotalBookingsState();
}

class _TotalBookingsState extends State<TotalBookings> {
  final bookingRef = FirebaseFirestore.instance.collection("bookings");

  String formatDate(Timestamp timestamp) {
    return DateFormat("dd MMM yyyy").format(timestamp.toDate());
  }

  String formatTime(Timestamp timestamp) {
    return DateFormat("hh:mm a").format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text("All Bookings"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),

      body: StreamBuilder(
        stream: bookingRef.orderBy("createdAt", descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const Center(child: Text("No bookings found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var b = bookings[index].data() as Map<String, dynamic>;

              // Extracting slot details (array)
              var slotData = (b["slots"] as List).isNotEmpty ? b["slots"][0] : null;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Turf Image + Name
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            b["turfimage"] ?? "",
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            b["turfname"] ?? "",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 10),

                    // User Info
                    Text("👤 ${b['username']}  (${b['usernumber']})",
                        style: const TextStyle(fontSize: 16)),

                    const SizedBox(height: 10),

                    // Date
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 18),
                        const SizedBox(width: 6),
                        Text("Date: ${formatDate(b['date'])}"),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Time Slot
                    if (slotData != null)
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 18),
                          const SizedBox(width: 6),
                          Text("Slot: ${slotData['slot']}"),
                        ],
                      ),

                    const SizedBox(height: 10),

                    // Payment Details
                    Row(
                      children: [
                        const Icon(Icons.currency_rupee, size: 18),
                        const SizedBox(width: 5),
                        Text(
                          "Amount: ₹${b['slotPrice'] + (b['rentalPrice'] ?? 0)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Text("Payment: "),
                        Text(
                          b["paystatus"] ?? "pending",
                          style: TextStyle(
                            color: b["paystatus"] == "paid" ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Text("Status: "),
                        Text(
                          b["status"] ?? "",
                          style: TextStyle(
                            color: b["status"] == "booked"
                                ? Colors.blue
                                : b["status"] == "completed"
                                    ? Colors.green
                                    : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Created at
                    Text(
                      "📌 Booked on: ${formatDate(b['createdAt'])} at ${formatTime(b['createdAt'])}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
