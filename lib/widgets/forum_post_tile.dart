import 'package:calmwaves_app/pages/forum_post_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ForumPostTile extends StatefulWidget {
  final String title;
  final String content;
  final String date;
  final String? profilePic;
  final String postId;
  final String userId;
  final int likeCount;

  const ForumPostTile({
    super.key,
    required this.title,
    required this.date,
    this.profilePic,
    required this.content,
    required this.postId,
    required this.userId,
    required this.likeCount,
  });

  @override
  State<ForumPostTile> createState() => _ForumPostTileState();
}

class _ForumPostTileState extends State<ForumPostTile> {
  bool hasLiked = false;
  int currentLikes = 0;
  late String currentUserId;
  bool canModify = false;

  @override
  void initState() {
    super.initState();
    currentLikes = widget.likeCount;
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _checkPermissions();
    _checkIfLiked();
  }

  Future<void> _checkPermissions() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    if (!userDoc.exists) return;

    final role = userDoc['userinfo']['role'];
    setState(() {
      canModify = currentUserId == widget.userId || role == 'admin';
    });
  }

  Future<void> _checkIfLiked() async {
    final doc = await FirebaseFirestore.instance
        .collection('forum')
        .doc(widget.postId)
        .get();
    final likedBy = List<String>.from(doc['likedBy'] ?? []);
    setState(() {
      hasLiked = likedBy.contains(currentUserId);
    });
  }

  Future<void> _toggleLike() async {
    final docRef =
        FirebaseFirestore.instance.collection('forum').doc(widget.postId);

    if (hasLiked) {
      await docRef.update({
        'like': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([currentUserId]),
      });
      setState(() {
        hasLiked = false;
        currentLikes--;
      });
    } else {
      await docRef.update({
        'like': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([currentUserId]),
      });
      setState(() {
        hasLiked = true;
        currentLikes++;
      });
    }
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final titleController = TextEditingController(text: widget.title);
    final contentController = TextEditingController(text: widget.content);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Bejegyzés szerkesztése"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Cím")),
            TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: "Tartalom"),
                maxLines: 4),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Mégse")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('forum')
                  .doc(widget.postId)
                  .update({
                'title': titleController.text.trim(),
                'content': contentController.text.trim(),
              });
              Navigator.pop(ctx);
            },
            child: const Text("Mentés"),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Törlés megerősítése"),
        content: const Text("Biztosan törlöd a bejegyzést és hozzászólásait?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Mégse")),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Törlés")),
        ],
      ),
    );

    if (confirmed == true) {
      final postRef =
          FirebaseFirestore.instance.collection('forum').doc(widget.postId);
      final comments = await postRef.collection('comment').get();
      for (var comment in comments.docs) {
        await comment.reference.delete();
      }
      await postRef.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ForumPostDetailScreen(),
            settings: RouteSettings(arguments: {
              'title': widget.title,
              'content': widget.content,
              'date': widget.date,
              'profilePic': widget.profilePic,
              'postId': widget.postId,
              'userId': widget.userId,
              'likeCount': currentLikes,
            }),
          ),
        );
      },
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            leading: widget.profilePic != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(widget.profilePic!),
                    radius: 24,
                  )
                : const CircleAvatar(child: Icon(Icons.person)),
            title: Text(widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.date),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    hasLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.redAccent,
                  ),
                  onPressed: _toggleLike,
                ),
                Text(currentLikes.toString()),
                if (canModify)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditDialog(context);
                      } else if (value == 'delete') {
                        _confirmAndDelete(context);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                          value: 'edit', child: Text('Szerkesztés')),
                      const PopupMenuItem(
                          value: 'delete', child: Text('Törlés')),
                    ],
                  ),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
