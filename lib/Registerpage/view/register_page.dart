import 'dart:convert';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical_app/Auth/authservice/auth_service.dart';
import 'package:medical_app/Auth/model/usermodel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  final _userFormKey = GlobalKey<FormState>();
  final _ownerFormKey = GlobalKey<FormState>();

  // Controllers for user fields
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _userNumberController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final TextEditingController _userconfirmPasswordController =
      TextEditingController();

  // Controllers for turf owner fields
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _turfNameController = TextEditingController();
  final TextEditingController _ownerEmailController = TextEditingController();
  final TextEditingController _ownerNumberController = TextEditingController();
  final TextEditingController _ownerPasswordController =
      TextEditingController();
  final TextEditingController _ownerlocationController =
      TextEditingController();
  final TextEditingController _ownerAddressController = TextEditingController();
  final TextEditingController _ownermorningrateController =
      TextEditingController();
  final TextEditingController _ownereveningrateController =
      TextEditingController();

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  final _authService = AuthService();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadToCloudinary(File imageFile) async {
    try {
      const cloudName =
          "dwpqkpbv0"; // 🔴 Replace with your Cloudinary cloud name
      const uploadPreset =
          "turf_upload"; // 🔴 Replace with your Cloudinary unsigned preset

      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      final request =
          http.MultipartRequest("POST", uri)
            ..fields['upload_preset'] = uploadPreset
            ..files.add(
              await http.MultipartFile.fromPath('file', imageFile.path),
            );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = json.decode(responseData);
        return jsonData["secure_url"]; // ✅ return image URL
      } else {
        debugPrint("Cloudinary upload failed: $responseData");
        return null;
      }
    } catch (e) {
      debugPrint("Cloudinary upload error: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0x40D9D9D9),
      hintText: hint,
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
        borderSide: BorderSide(color: Color(0xFFD4D4D4), width: 2.w),
        borderRadius: BorderRadius.circular(10).r,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: SizedBox(),
        backgroundColor: Colors.white,
        title: const Text("Register", style: TextStyle(color: Colors.black)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          tabs: const [Tab(text: "User"), Tab(text: "Turf Owner")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // -------- USER FORM ----------
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _userFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Full Name",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: _userNameController,
                    decoration: _inputDecoration("Enter your full name"),
                    validator:
                        (value) => value!.isEmpty ? "Enter your name" : null,
                  ),
                  SizedBox(height: 15.h),
                  const Text(
                    "Phone Number",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: _userNumberController,
                    keyboardType: TextInputType.phone, // ✅ numeric keyboard
                    decoration: _inputDecoration("Enter your phone number"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter your phone number";
                      }
                      if (value.length < 10) {
                        return "Phone number must be at least 10 digits";
                      }
                      return null; // ✅ valid
                    },
                  ),

                  SizedBox(height: 15.h),

                  const Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: _userEmailController,
                    decoration: _inputDecoration("Enter your email"),
                    validator:
                        (value) => value!.isEmpty ? "Enter your email" : null,
                  ),
                  SizedBox(height: 15.h),

                  const Text(
                    "Password",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: _userPasswordController,
                    obscureText: true,
                    decoration: _inputDecoration("Enter your password"),
                    validator:
                        (value) =>
                            value!.length < 6 ? "Min 6 characters" : null,
                  ),

                  SizedBox(height: 15.h),

                  const Text(
                    "Confirm Password",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: _userconfirmPasswordController,
                    obscureText: true,
                    decoration: _inputDecoration("Confirm your password"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm your password";
                      }
                      if (value != _userPasswordController.text) {
                        return "Passwords do not match";
                      }
                      return null; // ✅ no error
                    },
                  ),
                  const SizedBox(height: 30),

                  // Register Button
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        setState(() => _isLoading = true);
                        Usermodel body = Usermodel();
                        body.name =
                            _tabController.index == 0
                                ? _userNameController.text
                                : _ownerNameController.text;
                        body.turfname =
                            _tabController.index == 0
                                ? null
                                : _turfNameController.text;
                        body.email =
                            _tabController.index == 0
                                ? _userEmailController.text
                                : _ownerEmailController.text;
                        body.number =
                            _tabController.index == 0
                                ? _userNumberController.text
                                : _ownerNumberController.text;
                        body.city =
                            _tabController.index == 0
                                ? null
                                : _ownerNumberController.text;
                        body.address =
                            _tabController.index == 0
                                ? null
                                : _ownerAddressController.text;
                        body.morningRate =
                            _tabController.index == 0
                                ? null
                                : _ownermorningrateController.text;
                        body.eveningRate =
                            _tabController.index == 0
                                ? null
                                : _ownereveningrateController.text;
                        body.role =
                            _tabController.index == 0 ? "user" : "turfowner";
                        body.turfimage =
                            (_tabController.index == 0 ? null : _pickedImage)
                                as String?;

                        await _authService.userregister(
                          data: body,
                          password: _userPasswordController.text,
                          context: context,
                        );
                      },
                      child: Container(
                        height: 50.h,
                        width: 350.w,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 5, 90, 8),
                          borderRadius: BorderRadius.circular(15).r,
                        ),
                        child: Center(
                          child:
                              _isLoading
                                  ? SizedBox(
                                    height: 25.h,
                                    width: 25.h,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3.w,
                                    ),
                                  )
                                  : Text(
                                    "Register as User",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // -------- OWNER FORM ----------
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _ownerFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Owner Name",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: _ownerNameController,
                    decoration: _inputDecoration("Enter owner name"),
                    validator:
                        (value) => value!.isEmpty ? "Enter your name" : null,
                  ),
                  SizedBox(height: 15.h),

                  const Text(
                    "Phone Number",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: _ownerNumberController,
                    decoration: _inputDecoration("Enter your number"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter your phone number";
                      }
                      if (value.length < 10) {
                        return "Phone number must be at least 10 digits";
                      }
                      return null; // ✅ valid
                    },
                  ),
                  SizedBox(height: 15.h),

                  const Text(
                    "Turf Name",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: _turfNameController,
                    decoration: _inputDecoration("Enter turf name"),
                    validator:
                        (value) => value!.isEmpty ? "Enter turf name" : null,
                  ),
                  SizedBox(height: 15.h),

                  const Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: _ownerEmailController,
                    decoration: _inputDecoration("Enter your email"),
                    validator:
                        (value) => value!.isEmpty ? "Enter your email" : null,
                  ),
                  SizedBox(height: 15.h),

                  const Text(
                    "Password",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: _ownerPasswordController,
                    obscureText: true,
                    decoration: _inputDecoration("Enter your password"),
                    validator:
                        (value) =>
                            value!.length < 6 ? "Min 6 characters" : null,
                  ),
                  SizedBox(height: 15.h),
                  const Text(
                    "City",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: _ownerlocationController,

                    decoration: _inputDecoration("Enter your city"),
                    validator:
                        (value) =>
                            value!.isEmpty ? "Enter your location" : null,
                  ),
                  SizedBox(height: 15.h),

                  const Text(
                    "Address",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: _ownerAddressController,

                    decoration: _inputDecoration("Enter your address"),
                    validator:
                        (value) => value!.isEmpty ? "Enter your address" : null,
                  ),

                  SizedBox(height: 15.h),
                  const Text(
                    "Rate Per Hour",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: _ownermorningrateController,

                    decoration: _inputDecoration("Enter your Morning rate"),
                    validator:
                        (value) => value!.isEmpty ? "Enter your rate" : null,
                  ),

                  SizedBox(height: 15.h),

                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: _ownereveningrateController,

                    decoration: _inputDecoration("Enter your Fedlight rate"),
                    validator:
                        (value) => value!.isEmpty ? "Enter your rate" : null,
                  ),

                  SizedBox(height: 15.h),

                  // image pick from gallery i want it in a container like
                  const Text(
                    "Upload Turf Image",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 5.h),

                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12).r,
                        color: Colors.grey[200],
                      ),
                      child:
                          _pickedImage == null
                              ? Center(
                                child: Icon(
                                  Icons.add_a_photo,
                                  size: 50.r,
                                  color: Colors.grey,
                                ),
                              )
                              : ClipRRect(
                                borderRadius: BorderRadius.circular(12).r,
                                child: Image.file(
                                  _pickedImage!,
                                  width: double.infinity,
                                  height: 200.h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Register Button
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        if (_ownerFormKey.currentState!.validate()) {
                          setState(() => _isLoading = true);

                          String? imageUrl;

                          // 🔹 Upload image if picked
                          if (_pickedImage != null) {
                            imageUrl = await _uploadToCloudinary(_pickedImage!);
                          }

                          Usermodel body = Usermodel();
                          body.name =
                              _tabController.index == 0
                                  ? _userNameController.text
                                  : _ownerNameController.text;
                          body.turfname =
                              _tabController.index == 0
                                  ? null
                                  : _turfNameController.text;
                          body.email =
                              _tabController.index == 0
                                  ? _userEmailController.text
                                  : _ownerEmailController.text;
                          body.number =
                              _tabController.index == 0
                                  ? _userNumberController.text
                                  : _ownerNumberController.text;
                          body.city =
                              _tabController.index == 0
                                  ? null
                                  : _ownerlocationController.text;
                          body.address =
                              _tabController.index == 0
                                  ? null
                                  : _ownerAddressController.text;
                          body.morningRate =
                              _tabController.index == 0
                                  ? null
                                  : _ownermorningrateController.text;
                          body.eveningRate =
                              _tabController.index == 0
                                  ? null
                                  : _ownereveningrateController.text;
                          body.role =
                              _tabController.index == 0 ? "user" : "turfowner";
                          body.turfimage =
                              _tabController.index == 0 ? null : imageUrl;

                          await _authService.userregister(
                            data: body,
                            password: _ownerPasswordController.text,
                            context: context,
                          );
                        }
                      },
                      child: Container(
                        height: 50.h,
                        width: 350.w,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 5, 90, 8),
                          borderRadius: BorderRadius.circular(15).r,
                        ),
                        child: Center(
                          child:
                              _isLoading
                                  ? SizedBox(
                                    height: 25.h,
                                    width: 25.w,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3.w,
                                    ),
                                  )
                                  : Text(
                                    "Register as Turf Owner",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
