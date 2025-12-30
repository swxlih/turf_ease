import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final owneruid = FirebaseAuth.instance.currentUser!.uid;

  bool isLoadingFeatures = true;
  List<Map<String, dynamic>> reviews = [];

  Future<void> fetchreviews() async {
    try {
      // 🔹 2. Fetch Reviews Sub-collection
      QuerySnapshot<Map<String, dynamic>> reviewSnapshot =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(owneruid)
              .collection('reviews')
              .get();

      reviews =
          reviewSnapshot.docs.map((doc) {
            return {
              'comment': doc['comment'] ?? '',
              'rating': doc['rating'] ?? 0,
              'userid': doc['userid'] ?? '',
              'username': doc['username'] ?? '',
            };
          }).toList();

      setState(() {
        isLoadingFeatures = false;
      });
    } catch (e) {
      debugPrint("Error fetching details: $e");
      setState(() {
        isLoadingFeatures = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchreviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Reviews",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        centerTitle: true,
      ),
      body: isLoadingFeatures
    ? const Center(child: CircularProgressIndicator())
    : reviews.isEmpty
        ? const Center(child: Text("No reviews found"))
        : ListView.builder(
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final r = reviews[index];
        
            return Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(Icons.person,
                            color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          r['username'] ?? 'User',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < (r['rating'] ?? 0)
                                ? Icons.star
                                : Icons.star_border,
                            size: 18,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    r['comment'] ?? '',
                    style: const TextStyle(
                      fontSize: 14.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
    );
  }
}
