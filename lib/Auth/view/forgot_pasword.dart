import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/Auth/authservice/auth_service.dart';
import 'package:medical_app/widgets/custom_button.dart';
import 'package:medical_app/widgets/custom_textformfield.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: EdgeInsets.all(15.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 30.h),

              CustomTextFormField(
                label: "Email",
                hint: "Enter your registered email",
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required";
                  }
                  if (!RegExp(
                    r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return "Enter a valid email";
                  }
                  return null;
                },
              ),

              SizedBox(height: 30.h),

              CustomButton(
                title: "Send Reset Link",
                isLoading: isLoading,
                onTap: () async {
                  if (!_formKey.currentState!.validate()) return;

                  setState(() => isLoading = true);

                  await authService.forgotPassword(
                    email: _emailController.text.trim(),
                    context: context,
                  );

                  setState(() => isLoading = false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
