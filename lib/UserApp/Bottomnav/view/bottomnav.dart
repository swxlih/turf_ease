import 'package:flutter/material.dart';
import 'package:medical_app/UserApp/Booking/view/booking.dart';
import 'package:medical_app/UserApp/Homepage/view/home_page.dart';
import 'package:medical_app/UserApp/ProfilePage/view/profile.dart';
import 'package:medical_app/UserApp/notifications/view/notifications.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  ontap(index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get screens => [
    HomePage(),
    UserBookingsPage(),
    Notifications(),
    ProfileSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (value) {
          ontap(value);
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.date_range),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_outlined),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color.fromARGB(255, 12, 12, 12),
        showUnselectedLabels: true,
        backgroundColor: Colors.green.shade100,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
