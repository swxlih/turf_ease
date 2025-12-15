import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeController extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> allTurfs = [];
  List<Map<String, dynamic>> filteredTurfs = [];

  int selectedIndex = 0;
  final List<String> categories = ["All", "Football", "Cricket", "Badminton"];

  HomeController() {
    fetchTurfs();
    setupSearchListener();
  }

 // Greetings

  String get greeting {
  final hour = DateTime.now().hour;

  if (hour >= 5 && hour < 12) {
    return "Good Morning ☀️";
  } else if (hour >= 12 && hour < 17) {
    return "Good Afternoon 🌤️";
  } else if (hour >= 17 && hour < 21) {
    return "Good Evening 🌆";
  } else {
    return "Good Night 🌙";
  }
}


  
  // Fetch turfs from Firestore
  
  Future<void> fetchTurfs() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('role', isEqualTo: 'turfowner')
          .get();

      allTurfs = snapshot.docs.map((doc) => doc.data()).toList();
      filteredTurfs = allTurfs;

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching turf data: $e");
    }
  }

  
  // Search Filter Logic – updates filtered list when user types text
  
  void setupSearchListener() {
    searchController.addListener(() {
      final query = searchController.text.toLowerCase();

      filteredTurfs = allTurfs.where((turf) {
        final name = turf['turfname']?.toString().toLowerCase() ?? '';
        final address = turf['address']?.toString().toLowerCase() ?? '';
        return name.contains(query) || address.contains(query);
      }).toList();

      notifyListeners();
    });
  }

  // Category Filter Logic
  
  void filterByCategory(int index) {
    selectedIndex = index;

    if (index == 0) {
      filteredTurfs = allTurfs;
    } else {
      final selectedCategory = categories[index];

      filteredTurfs = allTurfs.where((turf) {
        final gameCategories =
            turf['game categories'] as Map<String, dynamic>? ?? {};

        return gameCategories[selectedCategory] == true;
      }).toList();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
