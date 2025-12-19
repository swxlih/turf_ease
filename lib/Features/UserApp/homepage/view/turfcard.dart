import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/Features/UserApp/Eachdetail/view/detail_page.dart';

class TurfCard extends StatelessWidget {
  final Map<String, dynamic> turf;

  const TurfCard({super.key, required this.turf});

  @override
  Widget build(BuildContext context) {
    final morningRate = turf['morningRate']?.toString() ?? 'N/A';
    final eveningRate = turf['eveningRate']?.toString() ?? 'N/A';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TurfDetailPage(
              turfname: turf['turfname'] ?? 'Unknown',
              imageUrl: turf['turfimage'] ?? '',
              morningruppes: morningRate,
              eveningrupees: eveningRate,
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
              offset: Offset(3.w, 7.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16).r,
              ),
              child: Image.network(
                turf['turfimage'] ?? '',
                height: 100.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          turf['turfname'] ?? 'Unknown',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(Icons.star, size: 16.sp, color: Colors.amberAccent),
                      Text(
                        "4.1",
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          turf['city'] ?? 'No city',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                      Icon(Icons.location_on_outlined,size: 15,)
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
