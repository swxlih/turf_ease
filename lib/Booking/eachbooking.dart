import 'package:flutter/material.dart';

class TurfBookingPage extends StatefulWidget {
  const TurfBookingPage({super.key});

  @override
  State<TurfBookingPage> createState() => _TurfBookingPageState();
}

class _TurfBookingPageState extends State<TurfBookingPage> {
  final List<String> dates = ['15 Jan', '16 Jan', '17 Jan', '18 Jan', '19 Jan', '20 Jan'];
  final List<String> times = ['06:00 am', '07:00 am', '08:00 am', '09:00 am'];
  final List<int> hours = [1, 2, 3, 4];

  int selectedDateIndex = 2;
  int selectedTimeIndex = 3;
  int selectedHoursIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Book Turf'),
        backgroundColor: Colors.green.shade100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date selection
            _buildSectionTitle('Date'),
            const SizedBox(height: 8),
            _buildSelectableList(
              items: dates,
              selectedIndex: selectedDateIndex,
              onTap: (index) => setState(() => selectedDateIndex = index),
            ),
            const SizedBox(height: 16),
            // Time selection   
            _buildSectionTitle('Time'),
            const SizedBox(height: 8),
            _buildSelectableList(
              items: times,
              selectedIndex: selectedTimeIndex,
              onTap: (index) => setState(() => selectedTimeIndex = index),
            ),
            const SizedBox(height: 16),
            // Hours selection
            _buildSectionTitle('Hours'),
            const SizedBox(height: 8),
            _buildSelectableList(
              items: hours.map((e) => e.toString()).toList(),
              selectedIndex: selectedHoursIndex,
              onTap: (index) => setState(() => selectedHoursIndex = index),
            ),
            const SizedBox(height: 16),
            // Invite Players
            _buildSectionTitle('Invite Players'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Tag your Friends', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Grand Total
            Center(
              child: Text(
                'Grand Total\n₹${600}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            // Proceed button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Proceed',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
  }

  Widget _buildSelectableList({
    required List<String> items,
    required int selectedIndex,
    required Function(int) onTap,
  }) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          bool isSelected = index == selectedIndex;
          return InkWell(
            onTap: () => onTap(index),
            child: Container(
              width: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? Colors.green.shade100 : Colors.white,
                border: Border.all(color: isSelected ? Colors.green.shade500 : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                items[index],
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.green : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
