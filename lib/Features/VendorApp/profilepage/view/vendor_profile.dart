import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/Auth/authservice/auth_service.dart';
import 'package:medical_app/Auth/view/login_page.dart';
import 'package:medical_app/Features/VendorApp/addbooking/view/vendor_bookadd.dart';
import 'package:medical_app/Features/VendorApp/addtournament/view/tournament_page.dart';

class VendorProfile extends StatefulWidget {
  const VendorProfile({super.key});

  @override
  State<VendorProfile> createState() => _VendorProfileState();
}

class _VendorProfileState extends State<VendorProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _authservice = AuthService();

  Map<String, dynamic>? userData;
  Map<String, bool> features = {};
  Map<String, bool> gameCategories = {};
  Map<String, dynamic>? rentalsdata;
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

            final featureData = data['features'] ?? {};
            features = {
              "bathroom": featureData['bathroom'] ?? false,
              "restArea": featureData['restArea'] ?? false,
              "parking": featureData['parking'] ?? false,
              "shower": featureData['shower'] ?? false,
            };

            final gameData = data['game categories'] ?? {};
            gameCategories = {
              "Football": gameData['Football'] ?? false,
              "Cricket": gameData['Cricket'] ?? false,
              "Badminton": gameData['Badminton'] ?? false,
              "Soapy Football":gameData['Soapy Football'] ?? false,
            };

            setState(() {
              rentalsdata = data['rentals'];
              isLoading = false;
            });
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

  Future<void> updateFeature(String key, bool value) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('Users').doc(user.uid).update({
        "features.$key": value,
      });
    }
  }

  Future<void> updateGameCategory(String key, bool value) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('Users').doc(user.uid).update({
        "game categories.$key": value,
      });
    }
  }

  Future<void> updaterentals() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('Users').doc(user.uid).update({
        "rentals": rentalsdata,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(child: Text("No user data found"))
              : CustomScrollView(
                  slivers: [
                    // Modern App Bar with Image
                    SliverAppBar(
                      expandedHeight: 280.h,
                      pinned: true,
                      backgroundColor: Colors.white,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          children: [
                            // Background gradient
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.green.shade400,
                                    Colors.green.shade700,
                                  ],
                                ),
                              ),
                            ),
                            // Content
                            Positioned(
                              bottom: 20.h,
                              left: 0,
                              right: 0,
                              child: Column(
                                children: [
                                  // Turf Image
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 60.r,
                                      backgroundImage: userData!['turfimage'] !=
                                                  null &&
                                              userData!['turfimage']
                                                  .toString()
                                                  .isNotEmpty
                                          ? NetworkImage(userData!['turfimage'])
                                          : const NetworkImage(
                                              "https://cdn-icons-png.flaticon.com/512/149/149071.png",
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  // Turf Name
                                  Text(
                                    userData!['turfname'] ?? "No Turf Name",
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  // Owner Name
                                  Text(
                                    "Owner: ${userData!['name'] ?? 'No Name'}",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Contact Info Section
                            _buildSectionCard(
                              title: "Contact Information",
                              icon: Icons.contact_phone,
                              child: Column(
                                children: [
                                  _buildInfoRow(
                                    Icons.email_outlined,
                                    "Email",
                                    userData!['email'] ?? 'N/A',
                                  ),
                                  Divider(height: 24.h),
                                  _buildInfoRow(
                                    Icons.phone_outlined,
                                    "Phone",
                                    userData!['number'] ?? 'N/A',
                                  ),
                                  Divider(height: 24.h),
                                  _buildInfoRow(
                                    Icons.location_city_outlined,
                                    "City",
                                    userData!['city'] ?? 'N/A',
                                  ),
                                  Divider(height: 24.h),
                                  _buildInfoRow(
                                    Icons.home_outlined,
                                    "Address",
                                    userData!['address'] ?? 'N/A',
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Pricing Section
                            _buildSectionCard(
                              title: "Pricing",
                              icon: Icons.monetization_on,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildPriceCard(
                                      "Morning Rate",
                                      "₹ ${userData!['morningRate'] ?? 'N/A'}",
                                      Icons.wb_sunny,
                                      Colors.orange.shade100,
                                      Colors.orange.shade700,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: _buildPriceCard(
                                      "Evening Rate",
                                      "₹ ${userData!['eveningRate'] ?? 'N/A'}",
                                      Icons.nightlight_round,
                                      Colors.indigo.shade100,
                                      Colors.indigo.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Tournament Button
                            _buildActionButton(
                              icon: Icons.emoji_events,
                              label: "Add Tournaments",
                              color: Colors.amber.shade600,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TournamentPage(),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 16.h),

                            // Features Section
                            _buildSectionCard(
                              title: "Facilities & Features",
                              icon: Icons.star,
                              child: Column(
                                children:
                                    features.keys.map((key) {
                                      return _buildFeatureCheckbox(
                                        key,
                                        features[key]!,
                                        (val) {
                                          if (val != null) {
                                            setState(() => features[key] = val);
                                            updateFeature(key, val);
                                          }
                                        },
                                      );
                                    }).toList(),
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Game Categories Section
                            _buildSectionCard(
                              title: "Available Sports",
                              icon: Icons.sports_soccer,
                              child: Column(
                                children:
                                    gameCategories.keys.map((key) {
                                      return _buildFeatureCheckbox(
                                        key,
                                        gameCategories[key]!,
                                        (val) {
                                          if (val != null) {
                                            setState(() =>
                                                gameCategories[key] = val);
                                            updateGameCategory(key, val);
                                          }
                                        },
                                      );
                                    }).toList(),
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Rentals Section
                            _buildSectionTitle("Rental Equipment", Icons.shopping_bag),
                            SizedBox(height: 12.h),

                            rentalTile(
                              title: "Football Boots",
                              data: rentalsdata!["football"]["boots"],
                              sizesEnabled: true,
                              onChanged: () => setState(() {}),
                            ),
                            SizedBox(height: 12.h),

                            rentalTile(
                              title: "Cricket Bat",
                              data: rentalsdata!["cricket"]["bat"],
                              sizesEnabled: false,
                              onChanged: () => setState(() {}),
                            ),
                            SizedBox(height: 12.h),

                            rentalTile(
                              title: "Badminton Racket",
                              data: rentalsdata!["badminton"]["racket"],
                              sizesEnabled: false,
                              onChanged: () => setState(() {}),
                            ),

                            SizedBox(height: 30.h),

                            // Logout Button
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await _authservice.signout(context);
                                  if (context.mounted) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text("Logout"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade500,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 50.w,
                                    vertical: 14.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ),
                            SizedBox(height: 30.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                floatingActionButton: SizedBox(
                  width: 100.w,


                  child: FloatingActionButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => VendorBookadd(
                      imageurl: userData!['turfimage'],
                       turfid: userData!['uid'],
                        turfname: userData!['turfname'],
                         eveningRate: userData!['eveningRate'],
                          morningRate: userData!['morningRate'],
                           isOwner: true),));
                  },
                  child: Text("Add Match"),
                  ),
                ),
    );
    
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: Colors.green.shade700, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: Colors.green.shade700, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.grey.shade900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard(
    String label,
    String price,
    IconData icon,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 28.sp),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: textColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            price,
            style: TextStyle(
              fontSize: 18.sp,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: Colors.grey.shade400, size: 16.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCheckbox(
    String label,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          SizedBox(
            height: 24.h,
            width: 24.w,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget rentalTile({
    required String title,
    required Map data,
    required bool sizesEnabled,
    required VoidCallback onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Switch(
                value: data["enabled"],
                onChanged: (value) {
                  data["enabled"] = value;
                  onChanged();
                },
                activeColor: Colors.green.shade600,
              ),
            ],
          ),
          if (data["enabled"]) ...[
            SizedBox(height: 16.h),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Price (₹)",
                prefixIcon: Icon(Icons.currency_rupee, size: 20.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              onChanged: (value) {
                data["price"] = int.tryParse(value) ?? 0;
              },
            ),
            SizedBox(height: 12.h),
            if (!sizesEnabled)
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Quantity Available",
                  prefixIcon: Icon(Icons.inventory, size: 20.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                onChanged: (value) {
                  data["quantity"] = int.tryParse(value) ?? 0;
                },
              ),
            if (sizesEnabled) ...[
              SizedBox(height: 8.h),
              Text(
                "Size-wise Quantity",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8.h),
              bootSizeQuantityEditor(data),
            ],
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await updaterentals();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Rental details updated"),
                      backgroundColor: Colors.green.shade600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.save),
                label: Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget bootSizeQuantityEditor(Map data) {
    List<String> sizes = ["6", "7", "8", "9", "10", "11"];

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children:
          sizes.map((size) {
            return Container(
              width: (MediaQuery.of(context).size.width - 80.w) / 3,
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Size $size",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                ),
                onChanged: (value) {
                  data["sizes"][size] = int.tryParse(value) ?? 0;
                },
              ),
            );
          }).toList(),
    );
  }
}