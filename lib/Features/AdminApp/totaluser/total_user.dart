import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TotalUser extends StatefulWidget {
  const TotalUser({super.key});

  @override
  State<TotalUser> createState() => _TotalUserState();
}

class _TotalUserState extends State<TotalUser> {
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('Users');

  // 🔥 Delete user
  Future<void> deleteUser(String userId) async {
    await usersRef.doc(userId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text("All Users"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),

      body: StreamBuilder(
        stream: usersRef.where("role", isEqualTo: "user").snapshots(),  // 👈 FILTER BY ROLE
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              var userDoc = users[index];
              var user = userDoc.data() as Map<String, dynamic>;

              String name = user['name'] ?? "Unknown";
              String phone = user['number'] ?? "Not available";
              String email = user['email'] ?? "No email";

              return Container(
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
                    backgroundColor: Colors.green.shade300,
                    child: const Icon(Icons.person, color: Colors.white),
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
                        Text("📞 $phone", style: const TextStyle(fontSize: 14)),
                        Text("📧 $email", style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),

                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _confirmDelete(context, userDoc.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🚨 Confirmation Dialog Before Delete
  void _confirmDelete(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Delete User"),
        content: const Text("Are you sure you want to delete this user? This action cannot be undone."),

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
              await deleteUser(userId);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("User deleted successfully."),
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
