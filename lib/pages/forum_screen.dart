import "package:calmwaves_app/widgets/custom_app_bar.dart";
import "package:calmwaves_app/widgets/custom_drawer.dart";
import "package:calmwaves_app/widgets/forum_post_tile.dart";
import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/new_post_popup.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.forum,
              ),
              label: "Fórum"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Kezdőlap"),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: "Események",
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            const Align(
              alignment: Alignment.center,
              child: Text(
                "Fórum",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            TextField(
              onChanged: (val) =>
                  setState(() => searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    25,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const NewPostPopup(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Új bejegyzés', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("forum")
                      .orderBy("date", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs.where((doc) {
                      final title = doc["title"].toString().toLowerCase();
                      return title.contains(searchQuery);
                    }).toList();

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text("Nincs találat"),
                      );
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index];
                        final userId = data['userId'];

                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .get(),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData) {
                              return const SizedBox();
                            }

                            final userData = userSnapshot.data!.data()
                                as Map<String, dynamic>;
                            final profilePic =
                                userData['userinfo']?['profilePicture'];

                            return ForumPostTile(
                              title: data['title'],
                              content: data['content'],
                              date: (data['date'] as Timestamp)
                                  .toDate()
                                  .toLocal()
                                  .toString()
                                  .split('.')[0],
                              postId: data.id,
                              userId: userId,
                              profilePic: profilePic,
                              likeCount: data['like'] ?? 0,
                            );
                          },
                        );
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
