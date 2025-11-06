import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/UserApp/Eachdetail/view/detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allTurfs = [];
  List<Map<String, dynamic>> filteredTurfs = [];
  int selectedIndex = 0;

  final List<String> categories = ["All", "Football", "Cricket", "Badminton"];

  @override
  void initState() {
    super.initState();
    fetchTurfs();

    // ✅ Search filtering
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        filteredTurfs =
            allTurfs.where((turf) {
              final name = turf['turfname']?.toString().toLowerCase() ?? '';
              final address = turf['address']?.toString().toLowerCase() ?? '';
              return name.contains(query) || address.contains(query);
            }).toList();
      });
    });
  }

  Future<void> fetchTurfs() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('Users')
              .where('role', isEqualTo: 'turfowner')
              .get();

      setState(() {
        allTurfs = snapshot.docs.map((doc) => doc.data()).toList();
        filteredTurfs = allTurfs;
      });
    } catch (e) {
      debugPrint("Error fetching turf data: $e");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void filterByCategory(int index) {
    setState(() {
      selectedIndex = index;

      if (index == 0) {
        // "All" selected
        filteredTurfs = allTurfs;
      } else {
        final selectedCategory = categories[index];

        // ✅ Filter by selected category being true in Firestore
        filteredTurfs =
            allTurfs.where((turf) {
              final gameCategories =
                  turf['game categories'] as Map<String, dynamic>? ?? {};
              return gameCategories[selectedCategory] == true;
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 👋 Greeting section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                   CircleAvatar(
                    radius: 25.r,
                    backgroundImage: NetworkImage(
                      "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                    ),
                  ),
                   SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  [
                      Text(
                        "Hello!",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Good morning 👋", style: TextStyle(fontSize: 14.sp)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.more_vert),
                ],
              ),
            ),

            // 🔍 Search bar
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 16.0.w),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search turf...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 241, 240, 240),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30).r,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

             SizedBox(height: 16.h),

            // 🏏 Category filter
            Padding(
              padding:  EdgeInsets.only(left: 16.w, top: 10.h),
              child: SizedBox(
                height: 40.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () => filterByCategory(index),
                      child: Container(
                        margin:  EdgeInsets.only(right: 12.w),
                        padding:  EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color:isSelected ? Colors.green : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20).r,
                        ),
                        child: Center(
                          child: Text(
                            categories[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

             SizedBox(height: 16.h),

            // 🏟️ Turf Grid
            Expanded(
              child:
                  allTurfs.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 16.w),
                        child: GridView.builder(
                          itemCount: filteredTurfs.length,
                          gridDelegate:
                               SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 20.w,
                                mainAxisSpacing: 20.h,
                                childAspectRatio: 0.9,
                              ),
                          itemBuilder: (context, index) {
                            final turf = filteredTurfs[index];
                            final moringrupees = turf['morningRate']?.toString() ?? 'N/A';
                            final eveningrupees = turf['eveningRate']?.toString() ?? 'N/A';

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => TurfDetailPage(
                                          turfname:
                                              turf['turfname'] ?? 'Unknown',
                                          imageUrl: turf['turfimage'] ?? '',
                                          morningruppes: moringrupees,
                                          eveningrupees: eveningrupees,
                                          ownerUid: turf['uid'] ?? '',
                                          address: turf['address'],
                                          city: turf['city'],
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16).r,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 3.r,
                                      offset:  Offset(3.w, 7.h),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius:  BorderRadius.vertical(
                                        top: Radius.circular(16).r,
                                      ),
                                      child: Image.network(
                                        turf['turfimage'] ?? '',
                                        height: 100.h,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image),
                                      ),
                                    ),
                                    Padding(
                                      padding:  EdgeInsets.all(8.w),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  turf['turfname'] ?? 'Unknown',
                                                  style:  TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                               Icon(
                                                Icons.favorite_border,
                                                size: 16.sp,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  turf['city'] ?? 'No city',
                                                  style:  TextStyle(
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                              ),
                                               Icon(
                                                Icons.star,
                                                size: 16.sp,
                                                color: Colors.amberAccent,
                                              ),
                                               Text(
                                                "4.1",
                                                style: TextStyle(fontSize: 12.sp),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
