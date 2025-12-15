import 'package:flutter/material.dart';
import 'package:medical_app/Features/UserApp/homepage/controller/home_controller.dart';
import 'package:medical_app/Features/UserApp/homepage/view/turfcard.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Provider.of<HomeController>(context);
    

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Greeting Header
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25.r,
                    backgroundImage: NetworkImage(
                        "https://cdn-icons-png.flaticon.com/512/3135/3135715.png"),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hello!", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      Text(home.greeting, style: TextStyle(fontSize: 14.sp)),
                    ],
                  ),
                 
                ],
              ),
            ),

            
            // Search Bar
         
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0.w),
              child: TextField(
                controller: home.searchController,
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

            
            // Category Filter
            
            Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: SizedBox(
                height: 40.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: home.categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = home.selectedIndex == index;
              
                    return GestureDetector(
                      onTap: () => home.filterByCategory(index),
                      child: Container(
                        margin: EdgeInsets.only(right: 12.w),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20).r,
                        ),
                        child: Center(
                          child: Text(
                            home.categories[index],
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

            
            // Turf Grid
            
            Expanded(
              child: home.filteredTurfs.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: home.filteredTurfs.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20.w,
                        mainAxisSpacing: 20.h,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (context, index) {
                        final turf = home.filteredTurfs[index];

                        return TurfCard(turf: turf);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}