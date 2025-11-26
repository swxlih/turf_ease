import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/Auth/view/login_page.dart';
import 'package:medical_app/Features/AdminApp/homepage/view/admin_homepage.dart';
import 'package:medical_app/Features/UserApp/Bottomnav/view/bottomnav.dart';
import 'package:medical_app/Features/VendorApp/bottomnav/view/vendor_bottomnav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString("uid");
      String? role = prefs.getString("role");

      if (uid != null && role != null) {
        if (role == "user") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => BottomNav()),
          );
        } else if (role == "turfowner") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => VendorBotomnav()),
            
          );
        } else if (role == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Adminhomepage()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // 🔹 Background Gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 13, 161, 25), // Dark Blue
              Color.fromARGB(255, 66, 245, 132), // Light Blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔹 Logo / Turf Icon
            Container(
              height: 120.h,
              width: 120.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.w),
              ),
              child: Center(child: Image.asset("assets/images/logo.png")),
            ),

            SizedBox(height: 25.w),

            // 🔹 App p
            Text(
              "TurfBook",
              style: TextStyle(
                fontSize: 32.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),

            SizedBox(height: 10.h),

            // 🔹 Tagline
            Text(
              "Find • Book • Play",
              style: TextStyle(fontSize: 16.sp, color: Colors.white70),
            ),

            SizedBox(height: 40.h),

            // 🔹 Loading Indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3.w,
            ),
          ],
        ),
      ),
    );
  }
}
