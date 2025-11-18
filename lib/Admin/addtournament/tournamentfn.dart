import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/Admin/addtournament/sendnotifcations.dart';

Future<void> addTournament(String name, String date) async {
  final doc = FirebaseFirestore.instance.collection("Tournaments").doc();

  await doc.set({
    "id": doc.id,
    "name": name,
    "date": date,
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

