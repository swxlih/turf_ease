import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/Auth/authservice/auth_service.dart';
import 'package:medical_app/Auth/view/forgot_pasword.dart';
import 'package:medical_app/Auth/view/register_page.dart';
import 'package:medical_app/widgets/custom_button.dart';
import 'package:medical_app/widgets/custom_textformfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final authSrevice = AuthService();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  bool _obscurepassword = true;
  // String? passwordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top image
              Container(
                height: 250.h,
                width: double.infinity,

                child: Image.asset(
                  "assets/images/soccer.png",
                  fit: BoxFit.cover,
                  height: 250.h,
                ),
              ),
              SizedBox(height: 15.h),

              // Title
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Text(
                    "Login",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26.sp,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // Email label
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: CustomTextFormField(
                  label: "Email",
                  hint: "Enter Your Email",
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Email is required";
                    }

                    // Simple email format check
                    if (!RegExp(
                      r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return "Enter a valid email";
                    }

                    return null;
                  },
                ),
              ),

              SizedBox(height: 15.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: CustomTextFormField(
                  label: "Password",
                  hint: "Enter Your Password",
                  controller: _passwordController,
                  obscure: _obscurepassword,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Enter your password";
                    return null;
                  },
                  suffixIcon: IconButton(
                    onPressed: (){
                    setState(() { });
                  _obscurepassword = !_obscurepassword;
                  }, icon: Icon(_obscurepassword ? Icons.visibility_off : Icons.visibility)),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(right: 19.w, top: 10.h),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: Text("Forgot Password?"),
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Login button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: CustomButton(
                  title: "Login",
                  isLoading: _isLoading,
                  onTap: () async {
                    if (!_formKey.currentState!.validate()) return;

                    setState(() {
                      _isLoading = true;
                    });

                    await authSrevice.loginUser(
                      emailController: _emailController.text,
                      passwordController: _passwordController.text,
                      context: context,
                    );

                    setState(() {
                      _isLoading = false;
                    });
                  },
                ),
              ),

              SizedBox(height: 20.h),

              // Register redirect
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don’t have an account?"),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        " Register",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
