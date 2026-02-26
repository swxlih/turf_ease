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
  List<String> reviewDocIds = [];

  Future<void> fetchreviews() async {
    try {
      QuerySnapshot<Map<String, dynamic>> reviewSnapshot =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(owneruid)
              .collection('reviews')
              .get();

      reviewDocIds = reviewSnapshot.docs.map((doc) => doc.id).toList();

      reviews = reviewSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'comment':  data['comment']  ?? '',
          'rating':   data['rating']   ?? 0,
          'userid':   data['userid']   ?? '',
          'username': data['username'] ?? '',
          'reply':    data['reply']    ?? '', // safe even if field doesn't exist
        };
      }).toList();

      setState(() {
        isLoadingFeatures = false;
      });
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
      if (!mounted) return;
      setState(() {
        isLoadingFeatures = false;
      });
    }
  }

  @override
  void initState() {
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
                    return ReviewCard(
                      key: ValueKey(reviewDocIds[index]),
                      review: reviews[index],
                      docId: reviewDocIds[index],
                      owneruid: owneruid,
                      onReplyUpdated: (newReply) {
                        reviews[index]['reply'] = newReply;
                      },
                    );
                  },
                ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Each card manages its own state → no full-list rebuild when replying
// ─────────────────────────────────────────────────────────────────────────────

class ReviewCard extends StatefulWidget {
  final Map<String, dynamic> review;
  final String docId;
  final String owneruid;
  final void Function(String newReply) onReplyUpdated;

  const ReviewCard({
    super.key,
    required this.review,
    required this.docId,
    required this.owneruid,
    required this.onReplyUpdated,
  });

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool isReplying = false;
  bool isSubmitting = false;
  late String currentReply;
  late TextEditingController replyController;

  @override
  void initState() {
    super.initState();
    currentReply = widget.review['reply'] ?? '';
    replyController = TextEditingController(text: currentReply);
  }

  @override
  void dispose() {
    replyController.dispose();
    super.dispose();
  }

  bool get hasReply => currentReply.isNotEmpty;

  Future<void> submitReply() async {
    final replyText = replyController.text.trim();
    if (replyText.isEmpty) return;

    setState(() => isSubmitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.owneruid)
          .collection('reviews')
          .doc(widget.docId)
          .update({'reply': replyText});

      setState(() {
        currentReply = replyText;
        isReplying = false;
        isSubmitting = false;
      });

      widget.onReplyUpdated(replyText);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reply submitted successfully")),
        );
      }
    } catch (e) {
      debugPrint("Error submitting reply: $e");
      setState(() => isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to submit reply")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.review;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          // ── User row ────────────────────────────────────────────────
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person, color: Colors.grey),
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
                    i < (r['rating'] ?? 0) ? Icons.star : Icons.star_border,
                    size: 18,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Comment ─────────────────────────────────────────────────
          Text(
            r['comment'] ?? '',
            style: const TextStyle(fontSize: 14.5, height: 1.4),
          ),

          const SizedBox(height: 12),

          // ── Existing reply (read-only) ───────────────────────────────
          if (hasReply && !isReplying)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.reply, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(
                        "Your Reply",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currentReply,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),

          // ── Reply text field ─────────────────────────────────────────
          if (isReplying) ...[
            TextField(
              controller: replyController,
              maxLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Write your reply...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => setState(() => isReplying = false),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isSubmitting ? null : submitReply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Submit"),
                ),
              ],
            ),
          ],

          // ── Reply / Edit button ──────────────────────────────────────
          if (!isReplying)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() => isReplying = true),
                icon: Icon(hasReply ? Icons.edit : Icons.reply, size: 16),
                label: Text(hasReply ? "Edit Reply" : "Reply"),
              ),
            ),
        ],
      ),
    );
  }
}