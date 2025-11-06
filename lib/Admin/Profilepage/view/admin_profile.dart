import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/Auth/login_page.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;
  Map<String, bool> features = {}; // ✅ Feature checkboxes
  Map<String, bool> gameCategories = {}; // ✅ Game category checkboxes
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAdminDetails();
  }

  Future<void> fetchAdminDetails() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final snapshot =
            await _firestore.collection('Users').doc(user.uid).get();

        if (snapshot.exists) {
          final data = snapshot.data()!;
          setState(() {
            userData = data;

            // ✅ Load features safely
            final featureData = data['features'] ?? {};
            features = {
              "bathroom": featureData['bathroom'] ?? false,
              "restArea": featureData['restArea'] ?? false,
              "parking": featureData['parking'] ?? false,
              "shower": featureData['shower'] ?? false,
            };

            // ✅ Load game categories safely
            final gameData = data['game categories'] ?? {};
            gameCategories = {
              "Football": gameData['Football'] ?? false,
              "Cricket": gameData['Cricket'] ?? false,
              "Badminton": gameData['Badminton'] ?? false,
            };

            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      debugPrint("Error fetching admin details: $e");
      setState(() => isLoading = false);
    }
  }

  // ✅ Update feature value in Firestore
  Future<void> updateFeature(String key, bool value) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('Users').doc(user.uid).update({
        "features.$key": value,
      });
    }
  }

  // ✅ Update game category value in Firestore
  Future<void> updateGameCategory(String key, bool value) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('Users').doc(user.uid).update({
        "game categories.$key": value,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(child: Text("No user data found"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ✅ Turf Image
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: userData!['turfimage'] != null &&
                                userData!['turfimage'].toString().isNotEmpty
                            ? NetworkImage(userData!['turfimage'])
                            : const NetworkImage(
                                "https://cdn-icons-png.flaticon.com/512/149/149071.png"),
                      ),
                      const SizedBox(height: 12),

                      // ✅ Turf Name
                      Text(
                        userData!['turfname'] ?? "No Turf Name",
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),

                      // ✅ Owner Name
                      Text(
                        "Owner: ${userData!['name'] ?? 'No Name'}",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      // ✅ Info Cards
                      infoTile(
                          icon: Icons.email,
                          title: "Email",
                          value: userData!['email'] ?? 'N/A'),
                      infoTile(
                          icon: Icons.phone,
                          title: "Phone",
                          value: userData!['number'] ?? 'N/A'),
                      infoTile(
                          icon: Icons.location_city,
                          title: "City",
                          value: userData!['city'] ?? 'N/A'),
                      infoTile(
                          icon: Icons.attach_money,
                          title: "Rate Per Hour",
                          value: "₹ ${userData!['rateperhour'] ?? 'N/A'}"),
                      infoTile(
                          icon: Icons.home,
                          title: "Address",
                          value: userData!['address'] ?? 'N/A'),

                      const SizedBox(height: 25),

                      // ✅ Features Section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Features",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...features.keys.map((key) {
                        return CheckboxListTile(
                          title: Text(key),
                          value: features[key],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => features[key] = val);
                              updateFeature(key, val);
                            }
                          },
                        );
                      }).toList(),

                      const SizedBox(height: 20),

                      // ✅ Game Categories Section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Game Categories",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...gameCategories.keys.map((key) {
                        return CheckboxListTile(
                          title: Text(key),
                          value: gameCategories[key],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => gameCategories[key] = val);
                              updateGameCategory(key, val);
                            }
                          },
                        );
                      }).toList(),

                      const SizedBox(height: 30),

                      // ✅ Logout Button
                      ElevatedButton.icon(
                        onPressed: () async {
                          await _auth.signOut();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text("Logout"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(value, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}
