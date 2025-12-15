import 'package:flutter/material.dart';
import 'package:medical_app/Features/VendorApp/profilepage/view/vendor_profile.dart';
import 'package:medical_app/Features/VendorApp/vendorhomepage/view/vendor_homepage.dart';


class VendorBotomnav extends StatefulWidget {
  const VendorBotomnav({super.key});

  @override
  State<VendorBotomnav> createState() => _VendorBotomnavState();
}

class _VendorBotomnavState extends State<VendorBotomnav> {

  int _selectedIndex=0;

  

 

  ontap(index){
    setState(() {
      _selectedIndex=index;
    });
  }
 List<Widget> get screens => [
        VendorHomepage(),
       
        VendorProfile()   
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