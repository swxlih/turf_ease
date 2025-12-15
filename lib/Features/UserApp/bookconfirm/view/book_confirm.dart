import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class BookingConfirmedPage extends StatelessWidget {
  final DateTime date;
  final List<String> slots;
  final String paymentId;

  const BookingConfirmedPage({
    super.key,
    required this.date,
    required this.slots,
    required this.paymentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text("Booking Confirmed"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Card(
            elevation: 4.r,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 80.sp),
                  SizedBox(height: 16.h),
                  Text(
                    "Payment Successful!",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Date: ${date.day}-${date.month}-${date.year}",
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Slots: ${slots.join(', ')}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Payment ID: $paymentId",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text("Back to Home"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}