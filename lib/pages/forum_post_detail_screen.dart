import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ForumPostDetailScreen extends StatefulWidget {
  const ForumPostDetailScreen({super.key});

  @override
  State<ForumPostDetailScreen> createState() => _ForumPostDetailScreenState();
}

class _ForumPostDetailScreenState extends State<ForumPostDetailScreen> {
  final _commentController = TextEditingController();

  Future<void> _showEditCommentDialog(
      String postId, String commentId, String oldContent) async {
    final controller = TextEditingController(text: oldContent);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hozzászólás szerkesztése"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Hozzászólás"),
          maxLines: 4,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Mégse")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('forum')
                  .doc(postId)
                  .collection('comment')
                  .doc(commentId)
                  .update({'content': controller.text.trim()});
              Navigator.pop(ctx);
            },
            child: const Text("Mentés"),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndDeleteComment(String postId, String commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Komment törlése"),
        content: const Text("Biztosan törölni szeretnéd ezt a hozzászólást?"),
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
      await FirebaseFirestore.instance
          .collection('forum')
          .doc(postId)
          .collection('comment')
          .doc(commentId)
          .delete();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<Map<String, dynamic>?> fetchUserInfo(String userId) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!snapshot.exists) return null;

    final userInfo = snapshot.data()?['userinfo'];
    if (userInfo == null || userInfo is! Map<String, dynamic>) return null;

    return userInfo;
  }

  Future<void> _addComment(String postId) async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser!;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final profilePic = userDoc['userinfo']?['profilePicture'];

    await FirebaseFirestore.instance
        .collection('forum')
        .doc(postId)
        .collection('comment')
        .add({
      'content': content,
      'userId': user.uid,
      'profilePic': profilePic,
      'date': Timestamp.now(),
    });

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final postId = args['postId'];
    final title = args['title'];
    final content = args['content'];
    final date = args['date'];
    final profilePic = args['profilePic'];
    final likeCount = args['likeCount'];

    return Scaffold(
      appBar: AppBar(title: const Text('Bejegyzés')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: profilePic != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(profilePic), radius: 24)
                  : const CircleAvatar(child: Icon(Icons.person)),
              title: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(date),
              trailing: Text("❤ $likeCount"), // TODO
            ),
            const SizedBox(height: 12),
            Text(content),
            const Divider(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Hozzászólások",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('forum')
                    .doc(postId)
                    .collection('comment')
                    .orderBy('date', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final comments = snapshot.data!.docs;
                  if (comments.isEmpty) {
                    return const Text('Nincsenek kommentek.');
                  }

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final commentId = comment.id;
                      final content = comment['content'];
                      final userId = comment['userId'];
                      final date = DateFormat('yyyy-MM-dd HH:mm').format(
                          (comment['date'] as Timestamp).toDate().toLocal());

                      return FutureBuilder<Map<String, dynamic>?>(
                        future: fetchUserInfo(userId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return ListTile(
                              title: Text(content),
                              subtitle: Text(date),
                              leading:
                                  const CircleAvatar(child: Icon(Icons.person)),
                            );
                          }

                          final userInfo = snapshot.data!;
                          final profileImage = userInfo['profileImage'] ?? "";

                          final currentUserId =
                              FirebaseAuth.instance.currentUser!.uid;
                          final isAdmin = userInfo['role'] == 'admin';
                          final canModify = currentUserId == userId || isAdmin;

                          return ListTile(
                            leading: profileImage.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(profileImage))
                                : const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(content),
                            subtitle: Text(date),
                            trailing: canModify
                                ? PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showEditCommentDialog(
                                            postId, commentId, content);
                                      } else if (value == 'delete') {
                                        _confirmAndDeleteComment(
                                            postId, commentId);
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Szerkesztés')),
                                      const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Törlés')),
                                    ],
                                  )
                                : null,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration:
                        const InputDecoration(hintText: "Új hozzászólás..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _addComment(postId),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
