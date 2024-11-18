import "package:calmwaves_app/pages/article_detail_screen.dart";
import "package:calmwaves_app/widgets/article_card.dart";
import "package:calmwaves_app/widgets/custom_app_bar.dart";
import "package:calmwaves_app/widgets/custom_drawer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
// import 'custom_app_bar.dart';
// import 'article_card.dart';
// import 'article_detail_screen.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final CollectionReference articlesCollection =
      FirebaseFirestore.instance.collection('articles');

  String filter = 'Hot';

  Future<void> _addArticle() async {
    // Új cikk hozzáadása a Firestore-hoz
    await articlesCollection.add({
      'title': 'Új cikk',
      'excerpt': 'Ez egy új cikk rövid összefoglalója...',
      'content': 'Ez egy új cikk teljes szövege...',
      'isFavorite': false,
    });
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
              stream: articlesCollection.snapshots(),
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
        onPressed: _addArticle,
        child: const Icon(Icons.add),
      ),
    );
  }
}
