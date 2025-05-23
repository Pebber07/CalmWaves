import "package:calmwaves_app/widgets/custom_drawer.dart";
import "package:flutter/material.dart";

/// Administrator accepts or denies the article written by a regular user.
class ArticleAcceptScreen extends StatelessWidget {
  final String title;
  final String content;
  const ArticleAcceptScreen(
      {super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                content,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
