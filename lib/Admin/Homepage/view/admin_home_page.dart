import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  // 🔹 Dummy booking data
  final List<Map<String, dynamic>> allBookings = [
    {
      'turfName': 'Green Field Turf',
      'userName': 'Rahul',
      'date': '2025-10-10',
      'time': '6:00 PM - 7:00 PM',
      'status': 'confirmed',
    },  
    {
      'turfName': 'Skyline Arena',
      'userName': 'Arjun',
      'date': '2025-10-12',                                         
      'time': '5:00 PM - 6:00 PM',
      'status': 'pending',
    },
    {
      'turfName': 'City Sports Turf',
      'userName': 'Vishnu',
      'date': '2025-10-05',
      'time': '7:00 AM - 8:00 AM',
      'status': 'completed',
    },
    {
      'turfName': 'Ocean View Ground',
      'userName': 'Ameer',
      'date': '2025-10-03',
      'time': '6:00 AM - 7:00 AM',
      'status': 'completed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // 🔸 Categorize data
    final now = DateTime.now();
    final upcomingBookings = allBookings
        .where((b) => DateTime.parse(b['date']).isAfter(now))
        .toList();
    final finishedBookings = allBookings
        .where((b) => DateTime.parse(b['date']).isBefore(now))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Turf Owner Dashboard"),
        backgroundColor: Colors.green,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.logout),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Summary Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryCard("Total", allBookings.length.toString(), Icons.list_alt),
                _buildSummaryCard("Upcoming", upcomingBookings.length.toString(), Icons.calendar_today),
                _buildSummaryCard("Finished", finishedBookings.length.toString(), Icons.check_circle),
              ],
            ),

            const SizedBox(height: 25),

            // 🔹 Upcoming Bookings Section
            const Text(
              "Upcoming Bookings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            upcomingBookings.isEmpty
                ? const Text("No upcoming bookings.", style: TextStyle(color: Colors.black54))
                : Column(
                    children: upcomingBookings.map((b) => _buildBookingTile(b)).toList(),
                  ),

            const SizedBox(height: 25),

            // 🔹 Finished Games Section
            const Text(
              "Finished Games",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            finishedBookings.isEmpty
                ? const Text("No finished games.", style: TextStyle(color: Colors.black54))
                : Column(
                    children: finishedBookings.map((b) => _buildBookingTile(b)).toList(),
                  ),

            const SizedBox(height: 25),

            // 🔹 All Bookings Section
            const Text(
              "All Bookings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: allBookings.map((b) => _buildBookingTile(b)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // 🔸 Summary Card Widget
  Widget _buildSummaryCard(String title, String count, IconData icon) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: Colors.green, size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(count, style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // 🔸 Booking Tile Widget
  Widget _buildBookingTile(Map<String, dynamic> booking) {
    Color statusColor;
    switch (booking['status']) {
      case 'confirmed':
        statusColor = Colors.green;
        break;
      case 'completed':
        statusColor = Colors.blue;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.sports_soccer, color: Colors.green),
        title: Text(
          booking['turfName'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${booking['date']} • ${booking['time']}\nBy: ${booking['userName']}",
          style: const TextStyle(fontSize: 13, height: 1.3),
        ),
        trailing: Text(
          booking['status'].toString().toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
      ),
    );
  }
}
