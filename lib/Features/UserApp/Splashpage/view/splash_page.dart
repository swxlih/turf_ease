import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/Auth/view/login_page.dart';
import 'package:medical_app/Features/AdminApp/homepage/view/admin_homepage.dart';
import 'package:medical_app/Features/UserApp/Bottomnav/view/bottomnav.dart';
import 'package:medical_app/Features/VendorApp/bottomnav/view/vendor_bottomnav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    // 🎥 Initialize video
    _videoController = VideoPlayerController.asset('assets/videos/bg.mp4')
      ..initialize().then((_) {
        _videoController
          ..setLooping(true)
          ..setVolume(0)
          ..play();
        setState(() {});
      });

    Timer(const Duration(seconds: 4), () async {
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
  void dispose() {
    // TODO: implement dispose
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🎥 Video Background
          SizedBox.expand(
            child:
                _videoController.value.isInitialized
                    ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    )
                    : const SizedBox(),
          ),

          // 🌑 Overlay for readability
          Container(color: Colors.black.withOpacity(0.4)),

          // 🌟 Splash Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  height: 120.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.w),
                  ),
                  child: Center(child: Image.asset("assets/images/logo1.png")),
                ),

                SizedBox(height: 25.h),

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

                Text(
                  "Find • Book • Play",
                  style: TextStyle(fontSize: 16.sp, color: Colors.white70),
                ),

                SizedBox(height: 40.h),

               
              ],
            ),
          ),
        ],
      ),
    );
  }
}
