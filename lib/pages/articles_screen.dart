import "package:calmwaves_app/pages/article_detail_screen.dart";
import "package:calmwaves_app/widgets/article_card.dart";
import "package:calmwaves_app/widgets/custom_app_bar.dart";
import "package:calmwaves_app/widgets/custom_drawer.dart";
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
  List<Map<String, dynamic>> articles = [
    {
      'title': 'Cikk 1',
      'excerpt': 'Ez a cikk rövid összefoglalója...',
      'content': 'Ez a teljes cikk szövege...',
      'isFavorite': false,
    },
    {
      'title': 'Cikk 2',
      'excerpt': 'Ez egy másik cikk összefoglalója...',
      'content': 'Ez egy másik teljes cikk szövege...',
      'isFavorite': false,
    },
  ];

  String filter = 'Hot';

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
            child: ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                if (filter == 'Favorites' && !article['isFavorite']) {
                  return const SizedBox.shrink();
                }
                return ArticleCard(
                  title: article['title'],
                  articleText: article['excerpt'],
                  isFavorite: article['isFavorite'],
                  onFavoriteToggle: () {
                    setState(() {
                      article['isFavorite'] = !article['isFavorite'];
                    });
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailScreen(
                          title: article['title'],
                          content: article['content'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
