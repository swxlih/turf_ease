import 'package:flutter/material.dart';
import 'package:medical_app/Auth/authservice/auth_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final authservice = AuthService();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: () async{
             await authservice.signout(context);
            },
            child: Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: Text("Turf Owner"),
      ),
    );
  }
}