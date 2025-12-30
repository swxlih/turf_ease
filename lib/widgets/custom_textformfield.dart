import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final String? Function(String?)? validator;
  final String? errorText; // <-- backend error support
  final IconButton? suffixIcon;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.validator,
    this.errorText, // <-- add here
    this.suffixIcon
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 5.h),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          decoration: _inputDecoration(hint).copyWith(
            errorText: errorText, // <--  shows backend error
          ),
          validator: validator,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0x40D9D9D9),
      hintText: hint,
      suffixIcon:suffixIcon,
      hintStyle: TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.w300,
        fontSize: 14.sp,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: const Color.fromARGB(255, 225, 225, 225),
          width: 1.w,
        ),
        borderRadius: BorderRadius.circular(10).r,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: const Color(0xFFD4D4D4), width: 2.w),
        borderRadius: BorderRadius.circular(10).r,
      ),
    );
  }
}
