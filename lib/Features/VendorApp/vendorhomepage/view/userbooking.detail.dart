import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserbookingDetail extends StatelessWidget {
  final String? turfName;
  final String? turfImage;
  final String? date;
  final String? rate;
  final String? paymentId;
  final String? status;
  final String? userName;
  final String? userNumber;
  final List<Map<String, dynamic>>? slots;

  const UserbookingDetail({
    super.key,
    required this.turfName,
    required this.turfImage,
    required this.date,
    required this.rate,
    required this.paymentId,
    required this.status,
    required this.userName,
    required this.userNumber,
    required this.slots,
  });

  Color get statusColor =>
      status == "booked" ? Colors.green : Colors.red;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Booking Details"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: SingleChildScrollView(
        padding:  EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // TURF IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.network(
                turfImage!,
                height: 200.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(height: 20.h),

            // TURF NAME + STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  turfName!,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status!.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            Text(
              date!,
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 20),

            _sectionCard(
              title: "User Details",
              children: [
                _tile("Name", userName!),
                _tile("Phone", userNumber!),
              ],
            ),

            SizedBox(height: 20),

            _sectionCard(
              title: "Payment Details",
              children: [
                _tile("Rate", "₹$rate"),
                _tile("Payment ID", paymentId!),
              ],
            ),

            SizedBox(height: 20),

            _sectionCard(
              title: "Booked Slots",
              children: slots!
                  .map((slot) => Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(slot["slot"], style: TextStyle(fontSize: 16)),
                            Icon(Icons.schedule, color: Colors.blue),
                          ],
                        ),
                      ))
                  .toList(),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Reusable Components
  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black12,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
          SizedBox(height: 16),
          ...children,
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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}