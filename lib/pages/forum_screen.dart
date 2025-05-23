import "package:calmwaves_app/widgets/custom_app_bar.dart";
import "package:calmwaves_app/widgets/custom_drawer.dart";
import "package:calmwaves_app/widgets/forum_post_tile.dart";
import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/new_post_popup.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// The public forum screen where the users can ask questions from users.
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context)!.forum,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
                hintText: AppLocalizations.of(context)!.search,
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
              child: Text(AppLocalizations.of(context)!.newEntry,
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
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
                      return Center(
                        child: Text(AppLocalizations.of(context)!.noDataFound),
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

                            final userDoc = userSnapshot.data!;
                            final rawData = userDoc.data();

                            if (rawData == null ||
                                rawData is! Map<String, dynamic>) {
                              return const SizedBox();
                            }

                            final userData = rawData;
                            final profilePic =
                                userData['userinfo']?['profileImage'];

                            return ForumPostTile(
                              title: data['title'],
                              content: data['content'],
                              date: DateFormat('yyyy-MM-dd HH:mm').format(
                                  (data['date'] as Timestamp)
                                      .toDate()
                                      .toLocal()),
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
