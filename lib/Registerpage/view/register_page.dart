import 'package:flutter/material.dart';
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
  final TextEditingController _ownerrateController = TextEditingController();
  // File? _pickedImage;
  // final ImagePicker _picker = ImagePicker();
  final _authService = AuthService();

  // Future<void> _pickImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

  //   if (pickedFile != null) {
  //     setState(() {
  //       _pickedImage = File(pickedFile.path);
  //     });
  //   }
  // }

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
      hintStyle: const TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.w300,
        fontSize: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 225, 225, 225),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFD4D4D4), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // void _registerUser() {
  //   if (_userFormKey.currentState!.validate()) {
  //     print("User registered: ${_userNameController.text}");
  //   }
  // }

  // void _registerOwner() {
  //   if (_ownerFormKey.currentState!.validate()) {
  //     print("Owner registered: ${_ownerNameController.text}");
  //   }
  // }

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
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _userFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Full Name",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _userNameController,
                    decoration: _inputDecoration("Enter your full name"),
                    validator:
                        (value) => value!.isEmpty ? "Enter your name" : null,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Phone Number",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 5),
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

                  const SizedBox(height: 15),

                  const Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _userEmailController,
                    decoration: _inputDecoration("Enter your email"),
                    validator:
                        (value) => value!.isEmpty ? "Enter your email" : null,
                  ),
                  const SizedBox(height: 15),

                  const Text(
                    "Password",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(  
                    controller: _userPasswordController,
                    obscureText: true,
                    decoration: _inputDecoration("Enter your password"),
                    validator:
                        (value) =>
                            value!.length < 6 ? "Min 6 characters" : null,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Confirm Password",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 5),
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
                        body.rateperhour =
                            _tabController.index == 0
                                ? null
                                : _ownerrateController.text;
                        body.role =
                            _tabController.index == 0 ? "user" : "turfowner";

                        await _authService.userregister(
                          data: body,
                          password: _userPasswordController.text,
                          context: context,
                        );
                      },
                      child: Container(
                        height: 50,
                        width: 350,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 5, 90, 8),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text(
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
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _ownerNameController,
                    decoration: _inputDecoration("Enter owner name"),
                    validator:
                        (value) => value!.isEmpty ? "Enter your name" : null,
                  ),
                  const SizedBox(height: 15),

                  const Text(
                    "Phone Number",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 5),
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
                  const SizedBox(height: 15),

                  const Text(
                    "Turf Name",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _turfNameController,
                    decoration: _inputDecoration("Enter turf name"),
                    validator:
                        (value) => value!.isEmpty ? "Enter turf name" : null,
                  ),
                  const SizedBox(height: 15),

                  const Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _ownerEmailController,
                    decoration: _inputDecoration("Enter your email"),
                    validator:
                        (value) => value!.isEmpty ? "Enter your email" : null,
                  ),
                  const SizedBox(height: 15),

                  const Text(
                    "Password",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _ownerPasswordController,
                    obscureText: true,
                    decoration: _inputDecoration("Enter your password"),
                    validator:
                        (value) =>
                            value!.length < 6 ? "Min 6 characters" : null,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "City",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _ownerlocationController,

                    decoration: _inputDecoration("Enter your city"),
                    validator:
                        (value) =>
                            value!.isEmpty ? "Enter your location" : null,
                  ),
                  const SizedBox(height: 15),

                  const Text(
                    "Address",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _ownerAddressController,

                    decoration: _inputDecoration("Enter your address"),
                    validator:
                        (value) => value!.isEmpty ? "Enter your address" : null,
                  ),

                  SizedBox(height: 15),

                  const SizedBox(height: 20),

                  // Register Button
                  Center(
                    child: GestureDetector(
                      onTap: () async {
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
                        body.rateperhour =
                            _tabController.index == 0
                                ? null
                                : _ownerrateController.text;
                        body.role =
                            _tabController.index == 0 ? "user" : "turfowner";

                        await _authService.userregister(
                          data: body,
                          password: _ownerPasswordController.text,
                          context: context,
                        );
                      },
                      child: Container(
                        height: 50,
                        width: 350,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 5, 90, 8),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text(
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
