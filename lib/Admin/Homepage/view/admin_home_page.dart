import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/Admin/Homepage/view/userbooking_detail.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int selectedtab = 0;

  Stream<QuerySnapshot> getadminBookings() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('turfbookings')
        .doc(user.uid)
        .collection('bookings')
        .snapshots();
  }

  Widget _filterTab(String label, int index) {
    final bool isSelected = selectedtab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedtab = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Turf Owner Dashboard"),
        backgroundColor: Colors.green,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: StreamBuilder<QuerySnapshot>(
          stream: getadminBookings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  "No bookings found 😔",
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                ),
              );
            }

            final bookings = snapshot.data!.docs;

            // ✅ Count total, upcoming, and finished bookings
            final totalCount = bookings.length;
            final now = DateTime.now();

            List<QueryDocumentSnapshot> pending = [];
            List<QueryDocumentSnapshot> finished = [];
            List<QueryDocumentSnapshot> displayList;

            int upcomingCount = 0;
            int finishedCount = 0;

           

            for (var doc in bookings) {
              final data = doc.data() as Map<String, dynamic>;
              List slots = data["slots"];
              // sort slots by endTime
              slots.sort(
                (a, b) => (a["endTime"] as Timestamp).compareTo(
                  b["endTime"] as Timestamp,
                ),
              );

              // last slot = end of booking time
              final lastSlot = slots.last;
              final endTime = (lastSlot["endTime"] as Timestamp).toDate();

              if (endTime.isBefore(now)) {
                finished.add(doc);
              } else {
                upcomingCount++;
                pending.add(doc);
              }
            }

             if (selectedtab == 0) {
              displayList = bookings;
            } else if (selectedtab == 1) {
              displayList = pending;
            } else {
              displayList = finished;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Summary Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSummaryCard("Total", totalCount, Icons.list_alt),
                    _buildSummaryCard(
                      "Upcoming",
                      upcomingCount,
                      Icons.calendar_today,
                    ),
                    _buildSummaryCard(
                      "Finished",
                      finishedCount,
                      Icons.check_circle,
                    ),
                  ],
                ),

                SizedBox(height: 30.h,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _filterTab("All", 0),
                    _filterTab("Pending", 1),
                    _filterTab("Finished", 2),
                  ],
                ),
                SizedBox(height: 20),

                SizedBox(height: 25.h),

                // All Bookings
               

                ListView.builder(
                  itemCount: displayList.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final booking = displayList[index];
                    final dateField = booking["date"];
                    String formattedDate = "";

                    if (dateField is Timestamp) {
                      final dateTime = dateField.toDate();
                      formattedDate = DateFormat(
                        'MMMM d, yyyy',
                      ).format(dateTime);
                    }

                    return GestureDetector(
                      onTap: () {
                        List<Map<String, dynamic>> slotList =
                            (booking['slots'] as List<dynamic>)
                                .map((e) => Map<String, dynamic>.from(e))
                                .toList();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => UserbookingDetail(
                                  turfName: booking['turfname'],
                                  turfImage: booking['turfimage'],
                                  date: formattedDate,
                                  rate: booking['rate'],
                                  paymentId: booking['paymentId'],
                                  status: booking['status'],
                                  userName: booking['username'],
                                  userNumber: booking['usernumber'],
                                  slots: slotList,
                                ),
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.sports_soccer,
                            color: Colors.green,
                          ),
                          title: Text(
                            booking['username'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 4.h),
                              if (booking["slots"] != null &&
                                  (booking["slots"] as List).isNotEmpty)
                                ...List.generate(
                                  (booking["slots"] as List).length,
                                  (i) {
                                    final slot = booking["slots"][i];
                                    return Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: 5.w),
                                        Text(
                                          slot["slot"] ?? "",
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                            ],
                          ),
                          trailing: Text(
                            booking['status'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  booking['status'] == 'booked'
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 20.h),

                // Text(
                //   "Pending",
                //   style: TextStyle(
                //     fontSize: 18.sp,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // SizedBox(height: 10.h),

                // ListView.builder(
                //   itemCount: pending.length,
                //   physics: const NeverScrollableScrollPhysics(),
                //   shrinkWrap: true,
                //   itemBuilder: (context, index) {
                //     final booking = pending[index];
                //     final dateField = booking["date"];
                //     String formattedDate = "";

                //     if (dateField is Timestamp) {
                //       final dateTime = dateField.toDate();
                //       formattedDate = DateFormat(
                //         'MMMM d, yyyy',
                //       ).format(dateTime);
                //     }

                //     return Card(
                //       margin: EdgeInsets.symmetric(vertical: 6.h),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12.r),
                //       ),
                //       child: ListTile(
                //         leading: const Icon(
                //           Icons.sports_soccer,
                //           color: Colors.green,
                //         ),
                //         title: Text(
                //           booking['username'],
                //           style: const TextStyle(fontWeight: FontWeight.bold),
                //         ),
                //         subtitle: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //               formattedDate,
                //               style: TextStyle(
                //                 fontSize: 13.sp,
                //                 color: Colors.grey[700],
                //               ),
                //             ),
                //             SizedBox(height: 4.h),
                //             if (booking["slots"] != null &&
                //                 (booking["slots"] as List).isNotEmpty)
                //               ...List.generate(
                //                 (booking["slots"] as List).length,
                //                 (i) {
                //                   final slot = booking["slots"][i];
                //                   return Row(
                //                     children: [
                //                       const Icon(
                //                         Icons.access_time,
                //                         size: 14,
                //                         color: Colors.green,
                //                       ),
                //                       SizedBox(width: 5.w),
                //                       Text(
                //                         slot["slot"] ?? "",
                //                         style: TextStyle(
                //                           fontSize: 13.sp,
                //                           color: Colors.grey[600],
                //                         ),
                //                       ),
                //                     ],
                //                   );
                //                 },
                //               ),
                //           ],
                //         ),
                //         trailing: Text(
                //           booking['status'],
                //           style: TextStyle(
                //             fontWeight: FontWeight.bold,
                //             color:
                //                 booking['status'] == 'booked'
                //                     ? Colors.green
                //                     : Colors.red,
                //           ),
                //         ),
                //       ),
                //     );
                //   },
                // ),
                // SizedBox(height: 20.h),

                // Text(
                //   "Finished",
                //   style: TextStyle(
                //     fontSize: 18.sp,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // SizedBox(height: 10.h),

                // ListView.builder(
                //   itemCount: finished.length,
                //   physics: const NeverScrollableScrollPhysics(),
                //   shrinkWrap: true,
                //   itemBuilder: (context, index) {
                //     final booking = finished[index];
                //     final dateField = booking["date"];
                //     String formattedDate = "";

                //     if (dateField is Timestamp) {
                //       final dateTime = dateField.toDate();
                //       formattedDate = DateFormat(
                //         'MMMM d, yyyy',
                //       ).format(dateTime);
                //     }

                //     return Card(
                //       margin: EdgeInsets.symmetric(vertical: 6.h),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12.r),
                //       ),
                //       child: ListTile(
                //         leading: const Icon(
                //           Icons.sports_soccer,
                //           color: Colors.green,
                //         ),
                //         title: Text(
                //           booking['username'],
                //           style: const TextStyle(fontWeight: FontWeight.bold),
                //         ),
                //         subtitle: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //               formattedDate,
                //               style: TextStyle(
                //                 fontSize: 13.sp,
                //                 color: Colors.grey[700],
                //               ),
                //             ),
                //             SizedBox(height: 4.h),
                //             if (booking["slots"] != null &&
                //                 (booking["slots"] as List).isNotEmpty)
                //               ...List.generate(
                //                 (booking["slots"] as List).length,
                //                 (i) {
                //                   final slot = booking["slots"][i];
                //                   return Row(
                //                     children: [
                //                       const Icon(
                //                         Icons.access_time,
                //                         size: 14,
                //                         color: Colors.green,
                //                       ),
                //                       SizedBox(width: 5.w),
                //                       Text(
                //                         slot["slot"] ?? "",
                //                         style: TextStyle(
                //                           fontSize: 13.sp,
                //                           color: Colors.grey[600],
                //                         ),
                //                       ),
                //                     ],
                //                   );
                //                 },
                //               ),
                //           ],
                //         ),
                //         trailing: Text(
                //           booking['status'],
                //           style: TextStyle(
                //             fontWeight: FontWeight.bold,
                //             color:
                //                 booking['status'] == 'booked'
                //                     ? Colors.green
                //                     : Colors.red,
                //           ),
                //         ),
                //       ),
                //     );
                //   },
                // ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 🔸 Summary Card Widget
  Widget _buildSummaryCard(String title, int count, IconData icon) {
    return Card(
      color: Colors.white,
      elevation: 2.w,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: 100.w,
        padding: EdgeInsets.all(14.w),
        child: Column(
          children: [
            Icon(icon, color: Colors.green, size: 28.sp),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.h),
            Text(
              "$count",
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
