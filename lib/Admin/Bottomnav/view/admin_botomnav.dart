import 'package:flutter/material.dart';
import 'package:medical_app/Admin/Homepage/view/admin_home_page.dart';
import 'package:medical_app/Admin/Profilepage/view/admin_profile.dart';


class AdminBotomnav extends StatefulWidget {
  const AdminBotomnav({super.key});

  @override
  State<AdminBotomnav> createState() => _AdminBotomnavState();
}

class _AdminBotomnavState extends State<AdminBotomnav> {

  int _selectedIndex=0;
  

  ontap(index){
    setState(() {
      _selectedIndex=index;
    });
  }
 List<Widget> get screens => [
        AdminHomePage(),
        
        AdminProfile()   
      ];  

  @override 
  Widget build(BuildContext context) {
    return Scaffold(

      body:screens[_selectedIndex] ,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (value) {
          ontap(value);
        },
        
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_outlined),
            label: 'Profile',
          ),
         
        ],
        selectedItemColor:Colors.white,
        unselectedItemColor: const Color.fromARGB(255, 12, 12, 12),
        showUnselectedLabels:true,
        backgroundColor: Colors.green.shade100,
        type: BottomNavigationBarType.fixed,

        
      ),
    );
  }

  
}