import 'package:flutter/material.dart';
import 'package:medical_app/Booking/eachbooking.dart';

class TurfDetailPage extends StatefulWidget {
  final String imageUrl;
  final String turfname;
  final int ruppes;
  const TurfDetailPage({super.key,required this.turfname,required this.imageUrl,required this.ruppes});

  @override
  State<TurfDetailPage> createState() => _TurfDetailPageState();
}

class _TurfDetailPageState extends State<TurfDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          // Turf image
          Container(
            height: 300,
            decoration:  BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Back button
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12)),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          // Bookmark icon
          Positioned(
            top: 40,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12)),
              child: IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () {},
              ),
            ),
          ),
          // White bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24)),
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Turf name & price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:  [
                        Text(
                          widget.turfname,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "₹ ${widget.ruppes}",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Address
                     Text(
                      "42, St Andrew's Road, D'Monte Park, Bandra West, Mumbai, 400050.",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    // Info icons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: const [
                            Icon(Icons.location_on, color: Colors.red),
                            SizedBox(height: 4),
                            Text("1.1 km")
                          ],
                        ),
                        Column(
                          children: const [
                            Icon(Icons.star, color: Colors.yellow),
                            SizedBox(height: 4),
                            Text("4.3")
                          ],
                        ),
                        Column(
                          children: const [
                            Icon(Icons.currency_rupee, color: Colors.green),
                            SizedBox(height: 4),
                            Text("per hour")
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Owner info
                    const Text("Owner",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                              "https://randomuser.me/api/portraits/men/32.jpg"),
                        ),
                        const SizedBox(width: 12),
                        const Text("Mr. Selvin Francis"),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.call),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.message),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Book Now button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TurfBookingPage(),));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child:  Text(
                          "Book Now",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              );  
            },
          ),
        ],
      ),
    );
  }
}
