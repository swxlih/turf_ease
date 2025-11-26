import 'package:flutter/material.dart';

class DetailNoti extends StatelessWidget {
  final String name;
  final String turfname;
  final String date;
  final String firstPrize;
  final String secondPrize;
  final String groundFee;
  final String createdAt;

  const DetailNoti({
    super.key,
    required this.name,
    required this.turfname,
    required this.date,
    required this.firstPrize,
    required this.secondPrize,
    required this.groundFee,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Tournament Details"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // HEADER CARD
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.sports_soccer, color: Colors.green),
                        SizedBox(width: 6),
                        Text(
                          turfname,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_month, color: Colors.blue),
                        SizedBox(width: 6),
                        Text(
                          date,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // PRIZES CARD
              _sectionCard(
                title: "Prizes",
                children: [
                  _tile("1st Prize", "₹$firstPrize"),
                  _tile("2nd Prize", "₹$secondPrize"),
                ],
              ),

              SizedBox(height: 20),

              // OTHER INFO CARD
              _sectionCard(
                title: "Additional Details",
                children: [
                  _tile("Ground Fee", "₹$groundFee"),
                  _tile("Posted On", createdAt),
                ],
              ),

              SizedBox(height: 30),
              
             
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Components
  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          ...children
        ],
      ),
    );
  }

  Widget _tile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
