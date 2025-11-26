import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final bool isLoading;
  final VoidCallback onTap;
  final double? height;
  final double? width;
  final Color color;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.title,
    required this.isLoading,
    required this.onTap,
    this.height,
    this.width,
    this.color = const Color.fromARGB(255, 5, 90, 8),
    this.borderRadius = 15,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: height ?? 50.h,
        width: width ?? 350.w,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius).r,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  height: 25.h,
                  width: 25.h,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3.w,
                  ),
                )
              : Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
        ),
      ),
    );
  }
}
