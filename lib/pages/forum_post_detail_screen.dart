import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        title: Text(AppLocalizations.of(context)!.modifyComment),
        content: TextField(
          controller: controller,
          decoration:
              InputDecoration(labelText: AppLocalizations.of(context)!.comment),
          maxLines: 4,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.cancel)),
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
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndDeleteComment(String postId, String commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteComment),
        content: Text(AppLocalizations.of(context)!.deleteCommentSure),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLocalizations.of(context)!.delete)),
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

  Future<void> _addComment(String postId) async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser!;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final profilePic = userDoc['userinfo']?['profileImage'];

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

  Future<String> getCurrentUserRole() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc['userinfo']?['role'] ?? 'user';
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

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.posts),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<String>(
          future: getCurrentUserRole(),
          builder: (context, roleSnapshot) {
            if (!roleSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final currentUserRole = roleSnapshot.data!;

            return Column(
              children: [
                ListTile(
                  leading: profilePic != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(profilePic), radius: 24)
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(date),
                  trailing: Text("❤ $likeCount"),
                ),
                const SizedBox(height: 12),
                Text(content),
                const Divider(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(AppLocalizations.of(context)!.comments,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
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
                        return Text(AppLocalizations.of(context)!.noComments);
                      }

                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final commentId = comment.id;
                          final content = comment['content'];
                          final userId = comment['userId'];
                          final date = DateFormat('yyyy-MM-dd HH:mm').format(
                              (comment['date'] as Timestamp)
                                  .toDate()
                                  .toLocal());
                          final profileImage = comment['profilePic'] ?? "";

                          final canModify = currentUserId == userId ||
                              currentUserRole == 'admin';

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
                                      PopupMenuItem(
                                          value: 'edit',
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .modify)),
                                      PopupMenuItem(
                                          value: 'delete',
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .delete)),
                                    ],
                                  )
                                : null,
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
                        decoration: InputDecoration(
                            hintText:
                                AppLocalizations.of(context)!.newPost), // Todo
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _addComment(postId),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
