import 'dart:convert';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical_app/Auth/authservice/auth_service.dart';
import 'package:medical_app/Auth/model/usermodel.dart';
import 'package:medical_app/widgets/custom_button.dart';
import 'package:medical_app/widgets/custom_textformfield.dart';

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
  final TextEditingController _ownerconfirmPasswordController =
      TextEditingController();
  final TextEditingController _ownerlocationController =
      TextEditingController();
  final TextEditingController _ownerAddressController = TextEditingController();
  final TextEditingController _ownermorningrateController =
      TextEditingController();
  final TextEditingController _ownereveningrateController =
      TextEditingController();
  bool _obscurepassword = true;
  bool _obscure2 = true;
  bool _obscure3 = true;
  bool _obscure4 = true;

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
                  CustomTextFormField(
                    label: "Full Name",
                    hint: "Enter Your full name",
                    controller: _userNameController,
                    validator:
                        (value) => value!.isEmpty ? "Enter your name" : null,
                  ),
                  SizedBox(height: 15.h),

                  CustomTextFormField(
                    label: "Phone Number",
                    hint: "Enter Your phone number",
                    controller: _userNumberController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter your phone number";
                      }
                      if (value.length < 10) {
                        return "Phone number must be at least 10 digits";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.h),

                  CustomTextFormField(
                    label: "Email",
                    hint: "Enter your email",
                    controller: _userEmailController,
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
                  SizedBox(height: 15.h),

                  CustomTextFormField(
                    label: "Password",
                    hint: "Enter your password",
                    controller: _userPasswordController,
                    obscure: _obscurepassword,
                    validator:
                        (value) =>
                            value!.length < 6 ? "Min 6 characters" : null,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {});
                        _obscurepassword = !_obscurepassword;
                      },
                      icon: Icon(
                        _obscurepassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),

                  CustomTextFormField(
                    label: "Confirm Password",
                    hint: "Confirm your password",
                    controller: _userconfirmPasswordController,
                    obscure: _obscure2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm your password";
                      }
                      if (value != _userPasswordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {});
                        _obscure2 = !_obscure2;
                      },
                      icon: Icon(
                        _obscure2 ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),

                  // Register Button
                  CustomButton(
                    title: "Register as user",
                    isLoading: _isLoading,
                    onTap: () async {
                      if (!_userFormKey.currentState!.validate()) {
                        return; // stop here, don't show loader
                      }

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

                      setState(() => _isLoading = false);
                    },
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
                  CustomTextFormField(
                    label: "Owner Name",
                    hint: "Enter owner name",
                    controller: _ownerNameController,
                    validator:
                        (value) => value!.isEmpty ? "Enter your name" : null,
                  ),
                  SizedBox(height: 15.h),

                  CustomTextFormField(
                    label: "Phone Number",
                    hint: "Enter your number",
                    controller: _ownerNumberController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter your phone number";
                      }
                      if (value.length < 10) {
                        return "Phone number must be at least 10 digits";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.h),

                  CustomTextFormField(
                    label: "Turf Name",
                    hint: "Enter turf name",
                    controller: _turfNameController,
                    validator:
                        (value) => value!.isEmpty ? "Enter turf name" : null,
                  ),
                  SizedBox(height: 15.h),

                  CustomTextFormField(
                    label: "Email",
                    hint: "Enter your email",
                    controller: _ownerEmailController,
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
                  SizedBox(height: 15.h),

                  CustomTextFormField(
                    label: "Password",
                    hint: "Enter your password",
                    controller: _ownerPasswordController,
                    obscure: _obscure3,
                    validator:
                        (value) =>
                            value!.length < 6 ? "Min 6 characters" : null,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {});
                        _obscure3 = !_obscure3;
                      },
                      icon: Icon(
                        _obscure3 ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),

                  CustomTextFormField(
                    label: "Confirm Password",
                   hint: "Confirm Your Password",
                    controller: _ownerconfirmPasswordController,
                    obscure: _obscure4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm your password";
                      }
                      if (value != _ownerPasswordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {});
                        _obscure4 = !_obscure4;
                      },
                      icon: Icon(
                        _obscure4 ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),

                    SizedBox(height: 15.h),

                  CustomTextFormField(
                    label: "City",
                    hint: "Enter your city",
                    controller: _ownerlocationController,
                    validator:
                        (value) =>
                            value!.isEmpty ? "Enter your location" : null,
                  ),
                  SizedBox(height: 15.h),

                  CustomTextFormField(
                    label: "Address",
                    hint: "Enter your address",
                    controller: _ownerAddressController,
                    validator:
                        (value) => value!.isEmpty ? "Enter your address" : null,
                  ),
                  SizedBox(height: 15.h),

                  CustomTextFormField(
                    label: "Rate Per Hour (Morning)",
                    hint: "Enter your Morning rate",
                    controller: _ownermorningrateController,
                    validator:
                        (value) => value!.isEmpty ? "Enter your rate" : null,
                  ),
                  SizedBox(height: 15.h),

                  CustomTextFormField(
                    label: "Rate Per Hour (Evening)",
                    hint: "Enter your Fedlight rate",
                    controller: _ownereveningrateController,
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
                  CustomButton(
                    title: "Register as Owner",
                    isLoading: _isLoading,
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
