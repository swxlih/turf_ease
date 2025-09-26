import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/Admin/Homepage/view/admin_home_page.dart';
import 'package:medical_app/Auth/login_page.dart';
import 'package:medical_app/Auth/model/usermodel.dart';
import 'package:medical_app/bottomnav.dart';

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
                  "rateperhour": data.rateperhour,
                  "citylist": generatePrefixes(data.city ?? 'N/A'),
                  "address": data.address,
                  "createdAt": Timestamp.now(),
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

  // Future<void> ownerregister({
  //    required Usermodel data,
  //    required String password,
  //   required BuildContext context,
  // }) async {
  //   try {
  //     // Create User with Email/Password
  //      await _auth
  //         .createUserWithEmailAndPassword(
  //           email:data.email??'N/A',
  //           password: password,
  //         )
  //         .then((UserCredential userCredential) async {
  //           await _firestore
  //               .collection("Turf Owners")
  //               .doc(userCredential.user!.uid)
  //               .set({
  //                 "uid": userCredential.user!.uid,
  //                 "name": data.name,
  //                 "turfname": data.turfname,
  //                 "email": data.email,
  //                 "number": data.number,
  //                 "city": data.city,
  //                 "role":data.role,
  //                 "rateperhour":data.rateperhour,
  //                 "citylist": generatePrefixes(data.city??'N/A'),
  //                 "address": data.address,
  //                 "createdAt": Timestamp.now(),
  //               })
  //               .then((value) {
  //                 Navigator.pop(context);
  //               });
  //         });

  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("Error: $e")));
  //   }
  // }

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
      // 🔹 Sign in with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.trim(),
        password: passwordController.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // Check in "users" collection
        DocumentSnapshot userDoc =
            await _firestore.collection('Users').doc(user.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          String role = userData['role'];

          // Shared Preferences
          

          if (role == 'user') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => BottomNav()),
              (route) => false,
            );
          } else if (role == 'turfowner') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AdminHomePage()),
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invalid role assigned.")),
            );
          }
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("No account data found.")));
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: ${e.message}")));
    }
  }


  // logout

  Future<void> signout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.remove('userId');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}
