import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/Features/AdminApp/totalowners/turfowner_fulldetail.dart';

class TotalOwners extends StatefulWidget {
  const TotalOwners({super.key});

  @override
  State<TotalOwners> createState() => _TotalOwnersState();
}

class _TotalOwnersState extends State<TotalOwners> {
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('Users');

  // 🔥 Delete owner
  Future<void> deleteOwner(String ownerId) async {
    await usersRef.doc(ownerId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text("Turf Owners"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),

      // 🔥 Fetch owners only (role = turfowner)
      body: StreamBuilder(
        stream: usersRef.where("role", isEqualTo: "turfowner").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Turf Owners Found"));
          }

          var owners = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: owners.length,
            itemBuilder: (context, index) {
              var ownerDoc = owners[index];
              var owner = ownerDoc.data() as Map<String, dynamic>;

              String name = owner['name'] ?? "Unknown";
              String phone = owner['number'] ?? "Not available";
              String email = owner['email'] ?? "No email";
              String turfName = owner['turfname'] ?? "No turf name"; // If available

              return InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TurfownerFulldetail(data: owner) ,));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.blue.shade300,
                      child: const Icon(Icons.store, color: Colors.white),
                    ),
                
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("🏟 Turf: $turfName"),
                          Text("📞 $phone"),
                          Text("📧 $email"),
                        ],
                      ),
                    ),
                
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _confirmDelete(context, ownerDoc.id);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🚨 Confirm before deleting owner
  void _confirmDelete(BuildContext context, String ownerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Delete Turf Owner"),
        content: const Text("Are you sure you want to delete this owner? This cannot be undone."),

        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Delete"),
            onPressed: () async {
              Navigator.pop(context);
              await deleteOwner(ownerId);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Owner deleted successfully."),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
