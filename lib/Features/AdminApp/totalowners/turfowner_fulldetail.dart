import 'package:flutter/material.dart';

class TurfownerFulldetail extends StatefulWidget {
  final Map<String, dynamic> data;

  const TurfownerFulldetail({super.key, required this.data});

  @override
  State<TurfownerFulldetail> createState() => _TurfownerFulldetailState();
}

class _TurfownerFulldetailState extends State<TurfownerFulldetail> {
  @override
  Widget build(BuildContext context) {
    var data = widget.data;

    return Scaffold(
      appBar: AppBar(
        title: Text("${data['turfname']} Details"),
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 Turf Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                data["turfimage"] ?? "",
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // 🌟 TURF OWNER BASIC DETAILS
            Text(
              data["turfname"] ?? "No Turf Name",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              "Owner: ${data['name'] ?? ''}",
              style: const TextStyle(fontSize: 18),
            ),

            Text(
              "Phone: ${data['number'] ?? ''}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            Text(
              "Email: ${data['email'] ?? ''}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const Divider(height: 30),

            // 📍 LOCATION DETAILS
            Text(
              "Location",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            Text("Address: ${data['address']}"),
            Text("City: ${data['city']}"),

            const Divider(height: 30),

            // 💰 PRICES
            Text(
              "Rates",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            Text("Morning Rate: ₹${data['morningRate'] ?? 'N/A'}"),
            Text("Evening Rate: ₹${data['eveningRate'] ?? 'N/A'}"),

            const Divider(height: 30),

            // ⚽ GAME CATEGORIES
            Text(
              "Game Categories",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            _buildSwitchTile("Badminton", data["game categories"]?["Badminton"]),
            _buildSwitchTile("Cricket", data["game categories"]?["Cricket"]),
            _buildSwitchTile("Football", data["game categories"]?["Football"]),

            const Divider(height: 30),

            // 🛠 FEATURES
            Text(
              "Features",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            _buildSwitchTile("Parking", data["features"]?["parking"]),
            _buildSwitchTile("Bathroom", data["features"]?["bathroom"]),
            _buildSwitchTile("Shower", data["features"]?["shower"]),
            _buildSwitchTile("Rest Area", data["features"]?["restArea"]),

            const Divider(height: 30),

            // 📦 RENTALS SECTION
            Text(
              "Rentals",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            _buildRentalSection("Badminton Rackets", data["rentals"]?["badminton"]?["racket"]),
            _buildRentalSection("Cricket Bats", data["rentals"]?["cricket"]?["bat"]),
            _buildRentalSection("Football Boots", data["rentals"]?["football"]?["boots"]),
          ],
        ),
      ),
    );
  }

  // 🔹 Helper widget to show true / false with icons
  Widget _buildSwitchTile(String title, bool? value) {
    return Row(
      children: [
        Icon(
          value == true ? Icons.check_circle : Icons.cancel,
          color: value == true ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  // 🔹 Rental Details
  Widget _buildRentalSection(String title, dynamic data) {
    if (data == null) return SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text("Enabled: ${data['enabled']}"),
          Text("Price: ₹${data['price']}"),
          Text("Quantity: ${data['quantity']}"),
        ],
      ),
    );
  }
}
