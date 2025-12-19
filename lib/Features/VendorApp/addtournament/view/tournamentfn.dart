import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addTournament(String name, String date ,String turfname, String groundfee,String firstprize,String secondprize,String commiteemember,String cmtnumber ) async {
  final doc = FirebaseFirestore.instance.collection("Tournaments").doc();

  await doc.set({
    "id": doc.id,
    "name": name,
    "date": date,
    "commitee":commiteemember,
    "number":cmtnumber,
    "turfname":turfname,
    "firstprize":firstprize,
    "secondprize":secondprize,
    "groundfee":groundfee, 
    "createdAt": FieldValue.serverTimestamp(),
  });
}