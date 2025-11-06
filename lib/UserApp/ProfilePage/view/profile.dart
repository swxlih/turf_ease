import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/Auth/login_page.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('Users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            userData = doc.data();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(child: Text("No user data found"))
              : Padding(
                  padding:  EdgeInsets.all(16.w),
                  child: ListView(
                    children: [
                      // Profile Header
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40.r,
                              backgroundImage: userData!['turfimage'] != null
                                  ? NetworkImage(userData!['turfimage'])
                                  : const NetworkImage(
                                      "https://cdn-icons-png.flaticon.com/512/3135/3135715.png"),
                            ),
                             SizedBox(height: 10.h),
                            Text(
                              userData!['name'] ?? "No name",
                              style:  TextStyle(
                                  fontSize: 18.sp, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              userData!['email'] ?? "No email",
                              style: const TextStyle(color: Colors.grey),
                            ),
                             SizedBox(height: 20.h),
                            ElevatedButton(
                              onPressed: () {
                                // TODO: Add edit profile page here
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 5, 90, 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: const Text(
                                "Edit Profile",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                             SizedBox(height: 30.h),
                          ],
                        ),
                      ),

                      _buildSectionTitle("Content"),
                      _buildListTile("Change Password", Icons.password_sharp),
                       SizedBox(height: 15.h),
                      _buildSectionTitle("Preferences"),
                      _buildListTile("Language", Icons.language,
                          trailingText: "English"),
                      _buildListTile("Notifications", Icons.notifications,
                          trailingText: "Enabled"),
                      _buildListTile("Theme", Icons.palette,
                          trailingText: "Light"),
                       SizedBox(height: 15.h),
                      _buildSectionTitle("Others"),
                      _buildListTile("Invite", Icons.connect_without_contact),
                      _buildListTile("Privacy", Icons.privacy_tip),
                      _buildListTile("Help", Icons.help),
                      _buildListTile("Logout", Icons.logout, onTap: () {
                        logout(context);
                      }),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding:  EdgeInsets.only(bottom: 10.h),
      child: Text(
        title,
        style:  TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
        ),
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon,
      {String trailingText = "", VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 5, 90, 8)),
      title: Text(title),
      trailing: trailingText.isNotEmpty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trailingText,
                  style: const TextStyle(color: Colors.grey),
                ),
                 Icon(Icons.arrow_forward_ios, size: 16.sp),
              ],
            )
          :  Icon(Icons.arrow_forward_ios, size: 16.sp),
      onTap: onTap,
    );
  }
}
