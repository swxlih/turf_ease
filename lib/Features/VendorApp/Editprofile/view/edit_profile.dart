import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/widgets/custom_button.dart';
import 'package:medical_app/widgets/custom_textformfield.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfile({super.key, required this.userData});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController _ownernameController = TextEditingController();
  late TextEditingController _ownernumberController = TextEditingController();
  late TextEditingController _ownerturfController = TextEditingController();
  late TextEditingController _owneremailController = TextEditingController();
  late TextEditingController _ownercityController = TextEditingController();
  late TextEditingController _owneraddressController = TextEditingController();
  late TextEditingController _morningrateController = TextEditingController();
  late TextEditingController _eveningrateController = TextEditingController();
  bool _isloading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _ownernameController = TextEditingController(text: widget.userData['name'] ?? '');
    _ownernumberController = TextEditingController(text: widget.userData['number']?? '');
    _ownerturfController = TextEditingController(text: widget.userData['turfname']?? '');
    _owneremailController = TextEditingController(text: widget.userData['email']?? '');
    _ownercityController = TextEditingController(text: widget.userData['city']?? '');
    _owneraddressController = TextEditingController(text: widget.userData['address']?? '');
    _morningrateController = TextEditingController(
      text: widget.userData['morningRate']?? '',
    );
    _eveningrateController = TextEditingController(
      text: widget.userData['eveningRate']?? '',
    );
  }

  Future<void> updateProfile() async {
  final uid = widget.userData['uid'];

  if (uid == null) return;

  await FirebaseFirestore.instance
      .collection('Users')
      .doc(uid)
      .update({
        "name": _ownernameController.text,
        "number": _ownernumberController.text,
        "turfname":_ownerturfController.text,
        "email":_owneremailController.text,
        "city": _ownercityController.text,
        "address": _owneraddressController.text,
        "morningRate": _morningrateController.text,
        "eveningRate": _eveningrateController.text,
      });

  Navigator.pop(context, true);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile"), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            children: [
              CustomTextFormField(
                label: "Owner Name",
                hint: "Enter Owner Name",
                controller: _ownernameController,
              ),
              SizedBox(height: 15.h),
              CustomTextFormField(
                label: "Phone Number",
                hint: "Enter Phone Number",
                controller: _ownernumberController,
              ),
              SizedBox(height: 15.h),
              CustomTextFormField(
                label: "Turf Name",
                hint: "Enter Turf Name",
                controller: _ownerturfController,
              ),
              SizedBox(height: 15.h),
              CustomTextFormField(
                label: "Email",
                hint: "Enter Your Email",
                controller: _owneremailController,
              ),
              SizedBox(height: 15.h),
              CustomTextFormField(
                label: "City",
                hint: "Enter Your City",
                controller: _ownercityController,
              ),
              SizedBox(height: 15.h),
              CustomTextFormField(
                label: "Address",
                hint: "Enter Your Address",
                controller: _owneraddressController,
              ),
              SizedBox(height: 15.h),
              CustomTextFormField(
                label: "Morning Rate",
                hint: "Enter Your Morning Rate",
                controller: _morningrateController,
              ),
              SizedBox(height: 15.h),
              CustomTextFormField(
                label: "Evening Rate",
                hint: "Enter Your Evening Rate",
                controller: _eveningrateController,
              ),
              SizedBox(height: 15.h),
              CustomButton(title: "Save", isLoading: _isloading, onTap: () {
                updateProfile();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
