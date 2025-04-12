import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForumPostDetailScreen extends StatefulWidget {
  const ForumPostDetailScreen({super.key});

  @override
  State<ForumPostDetailScreen> createState() => _ForumPostDetailScreenState();
}

class _ForumPostDetailScreenState extends State<ForumPostDetailScreen> {
  final _commentController = TextEditingController();
  bool _hasLiked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final postId = args['postId'];
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final doc =
        await FirebaseFirestore.instance.collection('forum').doc(postId).get();
    final data = doc.data();
    if (data != null && data['likedBy'] != null) {
      setState(() {
        _hasLiked = List<String>.from(data['likedBy']).contains(userId);
      });
    }
  }

  Future<void> _likePost(String postId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    if (_hasLiked) return;

    final docRef = FirebaseFirestore.instance.collection('forum').doc(postId);
    await docRef.update({
      'like': FieldValue.increment(1),
      'likedBy': FieldValue.arrayUnion([userId]),
    });

    setState(() {
      _hasLiked = true;
    });
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
              trailing: Column(
                children: [
                  IconButton(
                    icon: Icon(
                      _hasLiked ? Icons.favorite : Icons.favorite_border,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => _likePost(postId),
                  ),
                  Text((_hasLiked ? likeCount + 1 : likeCount).toString()),
                ],
              ),
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
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());

                  final comments = snapshot.data!.docs;
                  if (comments.isEmpty)
                    return const Text('Nincsenek kommentek.');

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final data = comments[index];
                      return ListTile(
                        leading: data['profilePic'] != null
                            ? CircleAvatar(
                                backgroundImage:
                                    NetworkImage(data['profilePic']),
                              )
                            : const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(data['content']),
                        subtitle: Text((data['date'] as Timestamp)
                            .toDate()
                            .toLocal()
                            .toString()
                            .split('.')[0]),
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
