import 'package:flutter/material.dart';
import 'package:medical_app/Auth/authservice/auth_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
 final authservice = AuthService();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding:  EdgeInsets.only(right: 20),
            child: InkWell(
              onTap: () async{
               await authservice.signout(context);
              },
              child: Icon(Icons.logout)),
          )
        ],
      ),
      body: Center(
        child: Text("profile screen"),
      ),
    );
  }
}