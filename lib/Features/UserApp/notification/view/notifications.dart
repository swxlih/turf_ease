import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/Features/UserApp/notification/view/detail_noti.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

  final firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection("Tournaments").snapshots(), 
        builder: (context, snapshot) {
           if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  "No Notifications found 😔",
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                ),
              );
            }

            final doc = snapshot.data!.docs;

        return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: doc.length,
        itemBuilder: (context, index) {
          final item = doc[index];

          

          return InkWell(
            onTap: () {

              Timestamp timestamp = item['createdAt'];
              DateTime dateTime = timestamp.toDate();
              String formatted = DateFormat('dd-MM-yyyy').format(dateTime);


              
              Navigator.push(context, MaterialPageRoute(builder: (context) =>DetailNoti(
                name: item['name'],
                turfname: item['turfname'],
                date: item['date'],
                groundFee: item['groundfee'],
                firstPrize: item['firstprize'],
                secondPrize:item['secondprize'] ,
                createdAt: formatted,
              ) ,));
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(Icons.notifications, color: Colors.black87),
                ),
                title: Text(
                  item["turfname"],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  item["name"],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  item["date"],
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            ),
          );
        },
      );
      },)
    );
  }
}