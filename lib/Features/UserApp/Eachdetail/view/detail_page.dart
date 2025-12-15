import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/Features/UserApp/Booking/view/each_booking.dart';

class TurfDetailPage extends StatefulWidget {
  final String imageUrl;
  final String turfname;
  final String morningruppes;
  final String eveningrupees;
  final String ownerUid;
  final String address;
  final String city;

  const TurfDetailPage({
    super.key,
    required this.turfname,
    required this.imageUrl,
    required this.morningruppes,
    required this.eveningrupees,
    required this.ownerUid,
    required this.address,
    required this.city,
  });

  @override
  State<TurfDetailPage> createState() => _TurfDetailPageState();
}

class _TurfDetailPageState extends State<TurfDetailPage> {
  String ownerName = "";
  String ownerNumber = "";
  Map<String, bool> features = {};
  bool isLoadingFeatures = true;
  List<Map<String, dynamic>> reviews = [];

  @override
  void initState() {
    super.initState();
    fetchOwnerDetails();
  }

  Future<void> fetchOwnerDetails() async {
    try {
      // 🔹 1. Fetch Owner Main Document
      DocumentSnapshot<Map<String, dynamic>> ownerDoc =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(widget.ownerUid)
              .get();

      if (ownerDoc.exists) {
        final data = ownerDoc.data();
        final featureData = data?['features'] ?? {};

        setState(() {
          ownerName = data?['name'] ?? 'Unknown Owner';
          ownerNumber = data?['number'] ?? '';
          features = {
            "Bathroom": featureData['bathroom'] ?? false,
            "Rest Area": featureData['restArea'] ?? false,
            "Parking": featureData['parking'] ?? false,
            "Shower": featureData['shower'] ?? false,
          };
        });
      }

      // 🔹 2. Fetch Reviews Sub-collection
      QuerySnapshot<Map<String, dynamic>> reviewSnapshot =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(widget.ownerUid)
              .collection('reviews')
              .get();

      reviews =
          reviewSnapshot.docs.map((doc) {
            return {
              'comment': doc['comment'] ?? '',
              'rating': doc['rating'] ?? 0,
              'userid': doc['userid'] ?? '',
              'username': doc['username'] ?? '',
            };
          }).toList();

      setState(() {
        isLoadingFeatures = false;
      });
    } catch (e) {
      debugPrint("Error fetching details: $e");
      setState(() {
        isLoadingFeatures = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          // Turf image
          Container(
            height: 300.h,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 40.h,
            left: 16.w,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 0.65,
            builder: (context, scrollController) {
              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Turf name, city & price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.turfname,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.city,
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 16.h),

                    // Address
                    Text(
                      widget.address,
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 16.h),

                    // Info icons row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 60.h,
                          width: 140.w,

                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Text("6:00 am - 6:00 pm"),
                                Text(
                                  "₹ ${widget.morningruppes}",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: 20.w),

                        Container(
                          height: 60.h,
                          width: 140.w,

                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Text("6:00 pm - 6:00 am"),
                                Text(
                                  "₹ ${widget.eveningrupees}",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Owner info
                    Text(
                      "Owner",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        CircleAvatar(radius: 20.r, child: Icon(Icons.person)),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            ownerName.isEmpty ? "Loading..." : ownerName,
                            style: TextStyle(fontSize: 15.sp),
                          ),
                        ),
                        if (ownerNumber.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.call),
                            onPressed: () {},
                          ),
                      
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Features
                    Text(
                      "Features",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    isLoadingFeatures
                        ? Column(
                          children: List.generate(
                            4, // assuming 4 features
                            (index) => Container(
                              margin: EdgeInsets.symmetric(vertical: 6.h),
                              height: 20.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                            ),
                          ),
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              features.entries
                                  .where((entry) => entry.value)
                                  .map(
                                    (entry) => Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 4.h,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(entry.key),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),

                    SizedBox(height: 16.h),

                    Text(
                      "Reviews",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),

                   ListView.builder(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  itemCount: reviews.length,
  itemBuilder: (context, index) {
    final r = reviews[index];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW → Icon | Name | Rating stars
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade200,
                child: Icon(Icons.person, color: Colors.grey, size: 26),
              ),
              SizedBox(width: 12),

              /// NAME
              Expanded(
                child: Text(
                  r['username'] ?? 'User',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              /// RATING
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < (r['rating'] ?? 0)
                        ? Icons.star
                        : Icons.star_border,
                    size: 18,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10),

          /// COMMENT
          Text(
            r['comment'] ?? '',
            style: TextStyle(
              fontSize: 14.5,
              color: Colors.black87,
              height: 1.4,
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
            },
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 30.w, right: 30.w, bottom: 20.h),
        child: SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TurfBookingPage(
                        turfid: widget.ownerUid,
                        turfname: widget.turfname,
                        imageurl: widget.imageUrl,
                        eveningRate: widget.eveningrupees,
                        morningRate: widget.morningruppes,
                      ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              "Book Now",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}