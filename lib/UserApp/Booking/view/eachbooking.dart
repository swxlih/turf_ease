import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/UserApp/provider/booking_provider.dart';
import 'package:medical_app/UserApp/provider/user_provider.dart';
import 'package:medical_app/UserApp/service/booking_service.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:intl/intl.dart';

class TurfBookingPage extends StatefulWidget {
  String imageurl;
  String turfid;
  String turfname;
  String? userid;
  String? username;
  String? usernumber;
  String morningRate;
  String eveningRate;
  TurfBookingPage({
    super.key,
    required this.imageurl,
    required this.turfid,
    required this.turfname,
   required this.eveningRate,
   required this.morningRate,
    this.userid,
    this.username,
    this.usernumber,
  });

  @override
  State<TurfBookingPage> createState() => _TurfBookingPageState();
}

class _TurfBookingPageState extends State<TurfBookingPage> {
  DateTime? selectedDate;
  List<String> selectedSlots = [];
  late Razorpay _razorpay;
  bool isLoadingRates = true;
  int? morningRate;
  int? eveningRate;
  int totalPrice = 0;

  final List<String> morningSlots = [
    "06:00 AM - 07:00 AM",
    "07:00 AM - 08:00 AM",
    "08:00 AM - 09:00 AM",
    "09:00 AM - 10:00 AM",
    "10:00 AM - 11:00 AM",
    "11:00 AM - 12:00 PM",
    "12:00 PM - 01:00 PM",
    "01:00 PM - 02:00 PM",
    "02:00 PM - 03:00 PM",
    "03:00 PM - 04:00 PM",
    "04:00 PM - 05:00 PM",
    "05:00 PM - 06:00 PM",
  ];

  final List<String> eveningSlots = [
    "06:00 PM - 07:00 PM",
    "07:00 PM - 08:00 PM",
    "08:00 PM - 09:00 PM",
    "09:00 PM - 10:00 PM",
    "10:00 PM - 11:00 PM",
    "11:00 PM - 12:00 AM",
    "12:00 AM - 01:00 AM",
    "01:00 AM - 02:00 AM",
    "02:00 AM - 03:00 AM",
    "03:00 AM - 04:00 AM",
    "04:00 AM - 05:00 AM",
    "05:00 AM - 06:00 AM",
  ];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchBookedSlotsByDate(widget.turfid, DateTime.now(), context);
    });

 morningRate = int.tryParse(widget.morningRate) ?? 0;
    eveningRate = int.tryParse(widget.eveningRate) ?? 0;
   }

  @override
  void dispose() {
    _razorpay.clear(); // very important
    super.dispose();
  }

  Future<void> fetchTurfRates(String turfId) async {
    final turfDoc =
        await FirebaseFirestore.instance
            .collection("turfbookings")
            .doc(turfId)
            .get();

    if (turfDoc.exists) {
      setState(() {
        // Convert string to int using int.tryParse()
        morningRate = int.tryParse(turfDoc['morningRate'].toString()) ?? 0;
        eveningRate = int.tryParse(turfDoc['eveningRate'].toString()) ?? 0;
        isLoadingRates = false;
      });
      print("✅ Fetched rates: Morning ₹$morningRate | Evening ₹$eveningRate");
    } else {
      print("⚠️ Turf document not found!");
    }
  }

  Future<void> pickDate() async {
    DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (date != null) {
      setState(() {
        selectedDate = date;
        selectedSlots.clear();
      });
      await fetchBookedSlotsByDate(widget.turfid, selectedDate!, context);
    }
  }

  void _openRazorpayCheckout() {
    var options = {
      'key': 'rzp_test_dxrCt5ZPpT9H0g', // ✅ Dummy Test Key (no real money)
      'amount': totalPrice * 100, // ₹500 (in paise)
      'name': 'Turf Booking (Demo)',
      'description': 'College Project Dummy Payment',
      'prefill': {'contact': '9999999999', 'email': 'demo@example.com'},
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ✅ Payment Success Handler
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      // Example values — replace with actual data from your app
      String userId =userProvider.userId; // 🔹 Replace with FirebaseAuth.instance.currentUser!.uid if using Auth
      String username = userProvider.username;
      String userphone = userProvider.phoneNumber;

      String turfId =
          widget.turfid; // 🔹 Pass this from previous page or turf details
      String rate = "$totalPrice"; // 🔹 Pass from turf data or selected rate

      final dateFormat = DateFormat("hh:mm a");

      // 🔹 Convert all selected slots into timestamp format
      List<Map<String, dynamic>> slotDetails =
          selectedSlots.map((slot) {
            final parts = slot.split(" - ");
            final start = dateFormat.parse(parts[0]);
            final end = dateFormat.parse(parts[1]);

            final startDateTime = DateTime(
              selectedDate!.year,
              selectedDate!.month,
              selectedDate!.day,
              start.hour,
              start.minute,
            );

            final endDateTime = DateTime(
              selectedDate!.year,
              selectedDate!.month,
              selectedDate!.day,
              end.hour,
              end.minute,
            );

            return {
              "slot": slot,
              "startTime": Timestamp.fromDate(startDateTime),
              "endTime": Timestamp.fromDate(endDateTime),
            };
          }).toList();

      // 🔹 Save booking details to Firestore after successful payment
      final bookingData = {
        "userId": userId,
        "usernumber": userphone,
        "username": username,
        "turfId": turfId,
        "turfname":widget.turfname ,
        "turfimage": widget.imageurl,
        "rate": rate,
        "date": Timestamp.fromDate(selectedDate!),
        "slots": slotDetails,
        "paymentId": response.paymentId ?? "N/A",
        "status": "booked",
        "createdAt": FieldValue.serverTimestamp(),
      };

      // Save in turf’s subcollection
      await FirebaseFirestore.instance
          .collection("turfbookings")
          .doc(turfId)
          .collection("bookings")
          .add(bookingData);

      // Save in user’s subcollection
      await FirebaseFirestore.instance
          .collection("usersbookings")
          .doc(userId)
          .collection("bookings")
          .add(bookingData);

      // 🔹 Navigate to booking confirmation page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => BookingConfirmedPage(
                date: selectedDate!,
                slots: selectedSlots,
                paymentId: response.paymentId ?? "N/A",
              ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Booking Confirmed & Saved!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving booking: $e")));
    }
  }

  // ❌ Payment Failure Handler
  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed! Please try again."),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  void bookTurf() {
    if (selectedDate == null || selectedSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select date and at least one time slot"),
        ),
      );
      return;
    }

    _openRazorpayCheckout(); // ✅ Dummy Payment Trigger
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Turf"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text("Select Date", style: TextStyle(fontSize: 16.sp)),
               SizedBox(height: 8.h),
              InkWell(
                onTap: pickDate,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 14.h,
                    horizontal: 12.w,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    selectedDate == null
                        ? "Select Date"
                        : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                    style:  TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
               SizedBox(height: 16.h),
               Text(
                "Select Time Slots",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
               SizedBox(height: 8 .h),

               Text("Morning Slots", style: TextStyle(fontSize: 16.sp)),
               SizedBox(height: 8.h),

              GridView.builder(
                itemCount: morningSlots.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 2.5,
                ),
                itemBuilder: (context, index) {
                  final slot = morningSlots[index];
                  final bookedSlots =
                      Provider.of<BookingProvider>(context).bookedSlots;
                  print("📋 Booked Slots from Provider: $bookedSlots");
                  final isBooked = bookedSlots.contains(slot);
                  final isSelected = selectedSlots.contains(slot);

                  return GestureDetector(
                    onTap:
                        isBooked
                            ? null
                            : () {
                              setState(() {
                                if (isSelected) {
                                  selectedSlots.remove(slot);
                                } else {
                                  selectedSlots.add(slot);
                                }

                                totalPrice = 0;
                                for (var s in selectedSlots) {
                                  if (morningSlots.contains(s)) {
                                    totalPrice += morningRate ?? 0;
                                  } else if (eveningSlots.contains(s)) {
                                    totalPrice += eveningRate ?? 0;
                                  }
                                }
                              });
                            },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            isBooked
                                ? Colors.red
                                : isSelected
                                ? Colors.blue
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color:
                              isBooked
                                  ? Colors.red
                                  : isSelected
                                  ? Colors.blue
                                  : Colors.grey,
                        ),
                      ),
                      child: Text(
                        slot,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color:
                              isBooked || isSelected
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
               SizedBox(height: 16.h),

               Text("Evening Slots", style: TextStyle(fontSize: 16.sp)),
               SizedBox(height: 8.h),

              GridView.builder(
                itemCount: eveningSlots.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 2.5,
                ),
                itemBuilder: (context, index) {
                  final slot = eveningSlots[index];
                  final bookedSlots =
                      Provider.of<BookingProvider>(context).bookedSlots;
                  final isBooked = bookedSlots.contains(slot);
                  final isSelected = selectedSlots.contains(slot);

                  return GestureDetector(
                    onTap:
                        isBooked
                            ? null
                            : () {
                              setState(() {
                                if (isSelected) {
                                  selectedSlots.remove(slot);
                                } else {
                                  selectedSlots.add(slot);
                                }

                                 totalPrice = 0;
                                for (var s in selectedSlots) {
                                  if (morningSlots.contains(s)) {
                                    totalPrice += morningRate ?? 0;
                                  } else if (eveningSlots.contains(s)) {
                                    totalPrice += eveningRate ?? 0;
                                  }
                                }



                              });
                            },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            isBooked
                                ? Colors.red
                                : isSelected
                                ? Colors.blue
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color:
                              isBooked
                                  ? Colors.red
                                  : isSelected
                                  ? Colors.blue
                                  : Colors.grey,
                        ),
                      ),
                      child: Text(
                        slot,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color:
                              isBooked || isSelected
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 20.w, bottom: 20.h, right: 20.w),
        child: SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: bookTurf,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child:  Text(
              "Book Now ₹ ${totalPrice}",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

/// ✅ Booking Confirmation Page (Fake for College Demo)
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
          padding:  EdgeInsets.all(24.w),
          child: Card(
            elevation: 4.r,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding:  EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Icon(Icons.check_circle, color: Colors.green, size: 80.sp),
                   SizedBox(height: 16.h),
                   Text(
                    "Payment Successful!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                   SizedBox(height: 12.h),
                  Text(
                    "Date: ${date.day}-${date.month}-${date.year}",
                    style:  TextStyle(fontSize: 16.sp),
                  ),
                   SizedBox(height: 6.h),
                  Text(
                    "Slots: ${slots.join(', ')}",
                    textAlign: TextAlign.center,
                    style:  TextStyle(fontSize: 16.sp),
                  ),
                   SizedBox(height: 6.h),
                  Text(
                    "Payment ID: $paymentId",
                    textAlign: TextAlign.center,
                    style:  TextStyle(fontSize: 14.sp, color: Colors.grey),
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
