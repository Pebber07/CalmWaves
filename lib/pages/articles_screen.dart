import "dart:convert";

import "package:calmwaves_app/pages/article_detail_screen.dart";
import "package:calmwaves_app/widgets/add_article.dart";
import "package:calmwaves_app/widgets/article_card.dart";
import "package:calmwaves_app/widgets/custom_app_bar.dart";
import "package:calmwaves_app/widgets/custom_drawer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:fluttertoast/fluttertoast.dart";

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final CollectionReference articlesCollection =
      FirebaseFirestore.instance.collection('articles');

  String filter = 'Hot';

  Future<void> _addArticleToFirestore(
    String title,
    String excerpt,
    String imageUrl,
    String content,
  ) async {
    final isAdmin = await _isAdmin();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Fluttertoast.showToast(msg: "Nincs bejelentkezve a felhasználó.");
      return;
    }

    if (isAdmin) {
      await articlesCollection.add({
        'title': title,
        'excerpt': excerpt,
        'content': content,
        'imageUrl': imageUrl,
        'isFavorite': true,
        'status': 'approved',
        'author': currentUser.uid,
      });
    } else {
      await articlesCollection.add({
        'title': title,
        'excerpt': excerpt,
        'content': content,
        'imageUrl': imageUrl,
        'isFavorite': true,
        'status': 'pending',
        'author': currentUser.uid,
      });
    }
  }

  Future<bool> _isAdmin() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;

    final userDoc =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();
    return userDoc.data()?["userinfo"]["role"] == "admin";
  }

  Future<void> _showAddArticlePopup(BuildContext context) async {
    TextEditingController titleController = TextEditingController();
    TextEditingController excerptController = TextEditingController();
    TextEditingController imageController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: AddArticle(
            articleTitle: "",
            articleImage: "",
            articleText: "",
            articleTitleController: titleController,
            articleExcerptController: excerptController,
            articleOptionalImageController: imageController,
            articleTextController: contentController,
            pressPostArticle: () async {
              Navigator.pop(context);
              await _addArticleToFirestore(
                titleController.text.trim(),
                excerptController.text.trim(),
                imageController.text.trim(),
                contentController.text.trim(),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: Text(
                'Articles',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    filter = 'Hot';
                  });
                },
                child: Text(
                  'Hot',
                  style: TextStyle(
                    color: filter == 'Hot' ? Colors.blue : Colors.black,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    filter = 'Favorites';
                  });
                },
                child: Text(
                  'Favorites',
                  style: TextStyle(
                    color: filter == 'Favorites' ? Colors.blue : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder(
              stream: articlesCollection
                  .where("status", isEqualTo: "approved")
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Nincsenek elérhető cikkek."),
                  );
                }
                final articles = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    final isFavorite = article["isFavorite"] as bool;

                    if (filter == "Favorites" && !isFavorite) {
                      return const SizedBox.shrink();
                    }

                    return ArticleCard(
                      title: article["title"],
                      articleText: article["excerpt"],
                      isFavorite: isFavorite,
                      onFavoriteToggle: () {
                        article.reference.update({'isFavorite': !isFavorite});
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticleDetailScreen(
                              title: article["title"] as String,
                              content: article["content"] as String,
                              imageUrl: article["imageUrl"] as String,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddArticlePopup(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
