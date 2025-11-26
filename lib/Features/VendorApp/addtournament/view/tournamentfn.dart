import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/Features/VendorApp/addtournament/view/sendnotifications.dart';

Future<void> addTournament(String name, String date ,String turfname, String groundfee,String firstprize,String secondprize ) async {
  final doc = FirebaseFirestore.instance.collection("Tournaments").doc();

  await doc.set({
    "id": doc.id,
    "name": name,
    "date": date,
    "turfname":turfname,
    "firstprize":firstprize,
    "secondprize":secondprize,
    "groundfee":groundfee, 
    "createdAt": FieldValue.serverTimestamp(),
  });

  // After creating tournament → send notification
  await sendNotificationToAllUsers(
    "New Tournament Added 🏆",
    "$name tournament is now open. Join now!"
  );

  // Save a notification entry in Firestore
  await saveNotificationForAllUsers(
    title: "New Tournament Added 🏆",
    body: "$name tournament is now open."
  );
}

Future<void> saveNotificationForAllUsers({
  required String title,
  required String body,
}) async {
  final doc = FirebaseFirestore.instance.collection("Notifications").doc();

  await doc.set({
    "id": doc.id,
    "title": title,
    "body": body,
    "createdAt": FieldValue.serverTimestamp(),
  });
}

