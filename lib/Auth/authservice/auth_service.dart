import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/Auth/view/login_page.dart';
import 'package:medical_app/Features/AdminApp/homepage/view/admin_homepage.dart';
import 'package:medical_app/Features/UserApp/Bottomnav/view/bottomnav.dart';
import 'package:medical_app/Features/UserApp/provider/user_provider.dart';
import 'package:medical_app/Auth/authservice/fsm.dart';
import 'package:medical_app/Auth/model/usermodel.dart';
import 'package:medical_app/Features/VendorApp/bottomnav/view/vendor_bottomnav.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> userregister({
    required Usermodel data,
    required String password,
    required BuildContext context,
  }) async {
    try {
      //  Create User with Email/Password

      await _auth
          .createUserWithEmailAndPassword(
            email: data.email ?? 'N/A',
            password: password,
          )
          .then((UserCredential userCredential) async {
            await _firestore
                .collection("Users")
                .doc(userCredential.user!.uid)
                .set({
                  "uid": userCredential.user!.uid,
                  "name": data.name,
                  "turfname": data.turfname,
                  "email": data.email,
                  "number": data.number,
                  "city": data.city,
                  "role": data.role,
                  "morningRate": data.morningRate,
                  "eveningRate": data.eveningRate,
                  "citylist": generatePrefixes(data.city ?? 'N/A'),
                  "address": data.address,
                  "turfimage": data.turfimage,
                  "createdAt": Timestamp.now(),
                  "fcmToken": "",
                  if (data.role == 'turfowner')
                    "features": {
                      "bathroom": false,
                      "restArea": false,
                      "parking": false,
                      "shower": false,
                    },
                  if (data.role == 'turfowner')
                    "game categories": {
                      "Football": false,
                      "Cricket": false,
                      "Badminton": false,
                    },

                  //rentals
                  if (data.role == "turfowner")
                    "rentals": {
                      "football": {
                        "boots": {
                          "enabled": false,
                          "price": 0,
                          "sizes": {
                            // size : quantity
                            "6":0,
                            "7": 0,
                            "8": 0,
                            "9": 0,
                            "10": 0,
                            "11": 0,
                          },
                        },
                      },
                      "cricket": {
                        "bat": {"enabled": false, "price": 0, "quantity": 0},
                      },
                      "badminton": {
                        "racket": {"enabled": false, "price": 0, "quantity": 0},
                      },
                    },
                })
                .then((value) {
                  Navigator.pop(context);
                });
          });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  List<String> generatePrefixes(String word) {
    List<String> result = [];
    for (int i = 1; i <= word.length; i++) {
      result.add(word.substring(0, i));
    }
    return result;
  }

  // common login

 Future<void> loginUser({
  required String emailController,
  required String passwordController,
  required BuildContext context,
}) async {
  try {

    // 🔥 STEP 1: Custom Admin Login BEFORE Firebase
    if (emailController.trim() == "admin@gmail.com" &&
        passwordController.trim() == "Admin@123") {
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("uid", "custom_admin");
      await prefs.setString("role", "admin");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Adminhomepage()),
        (route) => false,
      );
      print("✔ Custom admin logged in");
      return;
    }

    // 🔥 STEP 2: Firebase User Login
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: emailController.trim(),
      password: passwordController.trim(),
    );

    await NotificationService().updateFcmTokenAfterLogin();
    await FirebaseMessaging.instance.subscribeToTopic("all_users");

    User? user = userCredential.user;

    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(user.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>;
        String role = userData['role'];

        SharedPreferences prefs = await SharedPreferences.getInstance();

        if (role == 'user') {
          await prefs.setString("uid", user.uid);
          await prefs.setString("role", "user");

          Provider.of<UserProvider>(context, listen: false).setUser(
            userId: user.uid,
            username: userDoc['name'],
            phoneNumber: userDoc['number'],
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => BottomNav()),
            (route) => false,
          );

        } else if (role == 'turfowner') {
          await prefs.setString("uid", user.uid);
          await prefs.setString("role", "turfowner");

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => VendorBotomnav()),
            (route) => false,
          );

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid role assigned.")),
          );
        }
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No account data found.")));
    }

  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Login failed: ${e.message}")));
  }
}


  // logout

  Future<void> signout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}
