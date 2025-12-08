import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/Features/UserApp/provider/booking_provider.dart';
import 'package:medical_app/Features/UserApp/provider/user_provider.dart';
import 'package:medical_app/Features/UserApp/service/booking_service.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:intl/intl.dart';

class VendorBookadd extends StatefulWidget {
 final String imageurl;
 final  String turfid;
 final String turfname;
 final String morningRate;
 final String eveningRate;
 final bool isOwner;

 const VendorBookadd({
    super.key,
    required this.imageurl,
    required this.turfid,
    required this.turfname,
    required this.eveningRate,
    required this.morningRate,
    required this.isOwner
  });

  @override
  State<VendorBookadd> createState() => _VendorBookaddState();
}

class _VendorBookaddState extends State<VendorBookadd> {
  DateTime? selectedDate;
  List<String> selectedSlots = [];
  late Razorpay _razorpay;
  bool isLoadingRates = true;
  int? morningRate;
  int? eveningRate;
  int totalPrice = 0;
  Map<String, dynamic>? rentals;
  bool loading = true;
  String? selectedBootSize;
  bool rentBat = false;
  bool rentRacket = false;
  bool loadingrentals = true;
  int batCount = 0;
  int racketCount = 0;
  int bootCount = 0;

  Future<void> fetchTurfRentals() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.turfid)
          .get();

      setState(() {
        rentals = doc.data()?["rentals"] ?? {};
        loadingrentals = false;
      });
    } catch (e) {
      print("Error fetching rentals: $e");
      setState(() {
        loadingrentals = false;
      });
    }
  }

  num calculateRentalPrice() {
    num total = 0;

    // Boots - check if rentals and nested paths exist
    if (selectedBootSize != null &&
        rentals != null &&
        rentals!.containsKey("football") &&
        rentals!["football"]["boots"] != null) {
      total += bootCount * (rentals!["football"]["boots"]["price"] ?? 0);
    }

    // Cricket Bat - check if exists
    if (rentals != null &&
        rentals!.containsKey("cricket") &&
        rentals!["cricket"]["bat"] != null) {
      total += batCount * (rentals!["cricket"]["bat"]["price"] ?? 0);
    }

    // Racket - check if exists
    if (rentals != null &&
        rentals!.containsKey("badminton") &&
        rentals!["badminton"]["racket"] != null) {
      total += racketCount * (rentals!["badminton"]["racket"]["price"] ?? 0);
    }

    return total;
  }

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

    fetchTurfRentals();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> fetchTurfRates(String turfId) async {
    final turfDoc = await FirebaseFirestore.instance
        .collection("turfbookings")
        .doc(turfId)
        .get();

    if (turfDoc.exists) {
      setState(() {
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
        // Recalculate total price when date changes
        totalPrice = 0;
      });
      await fetchBookedSlotsByDate(widget.turfid, selectedDate!, context);
      
    }
  }

  void _openRazorpayCheckout() {
    // Calculate final price including rentals
    num finalPrice = totalPrice + calculateRentalPrice();
    
    var options = {
      'key': 'rzp_test_dxrCt5ZPpT9H0g',
      'amount': finalPrice * 100,
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

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      // String userId = userProvider.userId;
      String username = userProvider.username;
      String userphone = userProvider.phoneNumber;

      String turfId = widget.turfid;
      num finalPrice = totalPrice + calculateRentalPrice();
      String rate = "$finalPrice";
      
      
      final dateFormat = DateFormat("hh:mm a");

      List<Map<String, dynamic>> slotDetails = selectedSlots.map((slot) {
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

      // Prepare rental details
      Map<String, dynamic> rentalDetails = {};
      if (bootCount > 0 && selectedBootSize != null) {
        rentalDetails['boots'] = {
          'count': bootCount,
          'size': selectedBootSize,
          'price': rentals!["football"]["boots"]["price"] * bootCount,
        };
      }
      if (batCount > 0) {
        rentalDetails['bats'] = {
          'count': batCount,
          'price': rentals!["cricket"]["bat"]["price"] * batCount,
        };
      }
      if (racketCount > 0) {
        rentalDetails['rackets'] = {
          'count': racketCount,
          'price': rentals!["badminton"]["racket"]["price"] * racketCount,
        };
      }

      final bookingData = {
        "userId": userId,
        "usernumber": userphone,
        "username": username,
        "turfId": turfId,
        "turfname": widget.turfname,
        "turfimage": widget.imageurl,
        "rate": rate,
        "slotPrice": totalPrice,
        "rentalPrice": calculateRentalPrice(),
        "rentals": rentalDetails,
        "date": Timestamp.fromDate(selectedDate!),
        "slots": slotDetails,
        "paymentId": response.paymentId ?? "N/A",
        "status": "booked",
        "paystatus": "paid",
        "orderid": response.orderId,
        "signature": response.signature,
        "createdAt": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection("turfbookings")
          .doc(turfId)
          .collection("bookings")
          .add(bookingData);

      await FirebaseFirestore.instance
          .collection("usersbookings")
          .doc(userId)
          .collection("bookings")
          .add(bookingData);

      await FirebaseFirestore.instance
          .collection("bookings")
          .add(bookingData);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmedPage(
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving booking: $e")),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
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

  void bookTurf() async {
  if (selectedDate == null || selectedSlots.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please select date and at least one slot")),
    );
    return;
  }

  if (widget.isOwner) {
    await _saveOwnerManualBooking();
  } else {
    _openRazorpayCheckout();
  }
}


Future<void> _saveOwnerManualBooking() async {
  try {
    List<Map<String, dynamic>> slotDetails = selectedSlots.map((slot) {
      final parts = slot.split(" - ");
      final start = DateFormat("hh:mm a").parse(parts[0]);
      final end = DateFormat("hh:mm a").parse(parts[1]);
      

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

    String rate1 = "0";

    final bookingData = {
      "userId": "owner",
      "username": "Turf Owner",
      "usernumber": "N/A",
      "turfId": widget.turfid,
      "turfname": widget.turfname,
      "turfimage": widget.imageurl,

      "rate": rate1,
      "slotPrice": 0,
      "rentalPrice": 0,
      "rentals": {},

      "date": Timestamp.fromDate(selectedDate!),
      "slots": slotDetails,
      "paymentId": "manual",
      "orderid": "manual",
      "signature": "manual",
      "status": "booked",
      "paystatus": "not_applicable",

      "createdAt": FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection("turfbookings")
        .doc(widget.turfid)
        .collection("bookings")
        .add(bookingData);

    await FirebaseFirestore.instance
        .collection("bookings")
        .doc(widget.turfid)
        .collection("bookings")
        .add(bookingData);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Slot blocked successfully!")),
    );

    Navigator.pop(context);

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}



  void _updateTotalPrice() {
    totalPrice = 0;
    for (var s in selectedSlots) {
      if (morningSlots.contains(s)) {
        totalPrice += morningRate ?? 0;
      } else if (eveningSlots.contains(s)) {
        totalPrice += eveningRate ?? 0;
      }
    }
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
          padding: EdgeInsets.all(16.w),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate == null
                            ? "Select Date"
                            : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Rentals Section
              if (!loadingrentals && rentals != null) ...[
                Text(
                  "Rentals (Optional)",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),

                // FOOTBALL – BOOTS
                if (rentals!.containsKey("football") &&
                    rentals!["football"]["boots"] != null &&
                    rentals!["football"]["boots"]["enabled"] == true) ...[
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Football Boots",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Price: ₹${rentals!["football"]["boots"]["price"]} per boot",
                          ),
                          SizedBox(height: 8.h),
                          if (selectedBootSize == null)
                            ElevatedButton(
                              onPressed: () {
                                // Show size selection dialog
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Select Boot Size"),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: (rentals!["football"]["boots"]
                                                    ["sizes"] as Map)
                                            .keys
                                            .map<Widget>((size) {
                                          return ListTile(
                                            title: Text("Size $size"),
                                            subtitle: Text(
                                              "Available: ${rentals!["football"]["boots"]["sizes"][size]}",
                                            ),
                                            onTap: () {
                                              setState(() {
                                                selectedBootSize = size;
                                              });
                                              Navigator.pop(context);
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Text("Select Size"),
                            )
                          else ...[
                            Text("Selected Size: $selectedBootSize"),
                            Row(
                              children: [
                                Text("Quantity: "),
                                Spacer(),
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    if (bootCount > 0) {
                                      setState(() => bootCount--);
                                    }
                                  },
                                ),
                                Text("$bootCount"),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    int maxAvailable =
                                        rentals!["football"]["boots"]["sizes"]
                                            [selectedBootSize];
                                    if (bootCount < maxAvailable) {
                                      setState(() => bootCount++);
                                    }
                                  },
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedBootSize = null;
                                  bootCount = 0;
                                });
                              },
                              child: Text("Change Size"),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],

                // CRICKET – BAT
                if (rentals!.containsKey("cricket") &&
                    rentals!["cricket"]["bat"] != null &&
                    rentals!["cricket"]["bat"]["enabled"] == true) ...[
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Cricket Bat",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Price: ₹${rentals!["cricket"]["bat"]["price"]} per bat",
                          ),
                          Text(
                            "Available: ${rentals!["cricket"]["bat"]["quantity"]}",
                          ),
                          Row(
                            children: [
                              Text("Quantity: "),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  if (batCount > 0) {
                                    setState(() => batCount--);
                                  }
                                },
                              ),
                              Text("$batCount"),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  if (batCount <
                                      rentals!["cricket"]["bat"]["quantity"]) {
                                    setState(() => batCount++);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],

                // BADMINTON – RACKET
                if (rentals!.containsKey("badminton") &&
                    rentals!["badminton"]["racket"] != null &&
                    rentals!["badminton"]["racket"]["enabled"] == true) ...[
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Badminton Racket",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Price: ₹${rentals!["badminton"]["racket"]["price"]} per racket",
                          ),
                          Text(
                            "Available: ${rentals!["badminton"]["racket"]["quantity"]}",
                          ),
                          Row(
                            children: [
                              Text("Quantity: "),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  if (racketCount > 0) {
                                    setState(() => racketCount--);
                                  }
                                },
                              ),
                              Text("$racketCount"),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  if (racketCount <
                                      rentals!["badminton"]["racket"]
                                          ["quantity"]) {
                                    setState(() => racketCount++);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ],

              Text(
                "Select Time Slots",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),

              Text("Morning Slots", style: TextStyle(fontSize: 16.sp)),
              SizedBox(height: 8.h),

              GridView.builder(
                itemCount: morningSlots.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 2.5,
                ),
                itemBuilder: (context, index) {
                  final slot = morningSlots[index];
                  final bookedSlots =
                      Provider.of<BookingProvider>(context).bookedSlots;
                  final isBooked = bookedSlots.contains(slot);
                  final isSelected = selectedSlots.contains(slot);

                  return GestureDetector(
                    onTap: isBooked
                        ? null
                        : () {
                            setState(() {
                              if (isSelected) {
                                selectedSlots.remove(slot);
                              } else {
                                selectedSlots.add(slot);
                              }
                              _updateTotalPrice();
                            });
                          },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isBooked
                            ? Colors.red
                            : isSelected
                                ? Colors.blue
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isBooked
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
                              isBooked || isSelected ? Colors.white : Colors.black,
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
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                    onTap: isBooked
                        ? null
                        : () {
                            setState(() {
                              if (isSelected) {
                                selectedSlots.remove(slot);
                              } else {
                                selectedSlots.add(slot);
                              }
                              _updateTotalPrice();
                            });
                          },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isBooked
                            ? Colors.red
                            : isSelected
                                ? Colors.blue
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isBooked
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
                              isBooked || isSelected ? Colors.white : Colors.black,
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
            child: Text(
              widget.isOwner?"Block Slot":
              "Book Now ₹${totalPrice + calculateRentalPrice()}",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
                      fontSize: 22,
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