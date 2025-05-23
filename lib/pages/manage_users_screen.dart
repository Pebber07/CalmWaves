import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Manage Users Screen is only accessable for admin users, they can for instance delete user accounts.
class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  Future<void> _deleteUserAndContent(
      BuildContext context, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteProfile),
        content: Text(AppLocalizations.of(context)!.sureDelete),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLocalizations.of(context)!.delete)),
        ],
      ),
    );

    if (confirmed != true) return;

    final forumPosts = await FirebaseFirestore.instance
        .collection('forum')
        .where('userId', isEqualTo: userId)
        .get();

    for (final post in forumPosts.docs) {
      final postId = post.id;
      final comments = await FirebaseFirestore.instance
          .collection('forum')
          .doc(postId)
          .collection('comment')
          .get();

      for (final comment in comments.docs) {
        await comment.reference.delete();
      }

      await post.reference.delete();
    }

    // Comments at other posts.
    final allForumDocs =
        await FirebaseFirestore.instance.collection('forum').get();
    for (final doc in allForumDocs.docs) {
      final comments = await doc.reference.collection('comment').get();
      for (final comment in comments.docs) {
        if (comment['userId'] == userId) {
          await comment.reference.delete();
        }
      }
    }

    await FirebaseFirestore.instance.collection('users').doc(userId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.userAndDataDeleted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.handleUsers)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userId = user.id;
              final userInfo = user['userinfo'];
              final username =
                  userInfo['username'] ?? AppLocalizations.of(context)!.unknown;
              final role = userInfo['role'] ?? 'user';

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(username),
                subtitle: Text("${AppLocalizations.of(context)!.role}: $role"),
                trailing: role != 'admin'
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUserAndContent(context, userId),
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
