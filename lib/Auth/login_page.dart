import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/Auth/authservice/auth_service.dart';
import 'package:medical_app/Registerpage/view/register_page.dart';

class LoginPage extends StatefulWidget {
 const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final authSrevice = AuthService();

  @override
  Widget build(BuildContext context) {

     


    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top image
            Container(
              height: 250.h,
              width: double.infinity,
             

              child: Image.asset("assets/images/soccer.png",fit: BoxFit.cover,height: 250.h,),
            ),
            SizedBox(height: 15.h),

            // Title
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Text(
                  "Login",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26.sp),
                ),
              ),
            ),

            SizedBox(height: 30.h),

            // Email label
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: Text(
                "Email",
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
            ),
            // Email field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
              child: SizedBox(
                height: 50.h,
                width: double.infinity,
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0x40D9D9D9),
                    hintText: "Enter Your Email",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w300,
                      fontSize: 14.sp,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 225, 225, 225),
                        width: 1.w,
                      ),
                      borderRadius: BorderRadius.circular(10).r,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD4D4D4),
                        width: 2.w,
                      ),
                      borderRadius: BorderRadius.circular(10).r,
                    ),
                  ),
                ),
              ),
            ),

            // Password label
            Padding(
              padding: EdgeInsets.only(left: 15.w, top: 10.h),
              child: Text(
                "Password",
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
            ),
            // Password field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
              child: SizedBox(
                height: 50.h,
                width: double.infinity,
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0x40D9D9D9),
                    hintText: "Enter Your Password",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w300,
                      fontSize: 14.sp,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 225, 225, 225),
                        width: 1.w,
                      ),
                      borderRadius: BorderRadius.circular(10).r,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD4D4D4),
                        width: 2.w,
                      ),
                      borderRadius: BorderRadius.circular(10).r,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 40.h),

            // Login button
            Center(
              child: GestureDetector(
                onTap: () async{
                 await authSrevice.loginUser(emailController: _emailController.text, passwordController: _passwordController.text, context: context);
                },
                child: Container(
                  height: 50.h,
                  width: 350.w,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 5, 90, 8),
                    borderRadius: BorderRadius.circular(15).r,
                  ),
                  child: Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
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
                        MaterialPageRoute(builder: (context) => RegisterPage()),
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
    );
  }
}
