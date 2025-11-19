import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/Auth/login_page.dart';
import 'package:medical_app/UserApp/Bottomnav/view/bottomnav.dart';
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
      String? userId = prefs.getString("uid");
      
      if (userId != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => BottomNav()),(route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),(route) => false,
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
              Color.fromARGB(255, 13, 161, 25),  // Dark Blue
              Color.fromARGB(255, 66, 245, 132),  // Light Blue
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
              child:  Center(
                child: Image.asset("assets/images/logo.png")
              ),
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
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white70,
              ),
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
