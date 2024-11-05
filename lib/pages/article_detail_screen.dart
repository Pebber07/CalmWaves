import "package:flutter/material.dart";

class ArticleDetailScreen extends StatelessWidget {
  final String title;
  final String content;
  const ArticleDetailScreen({
    super.key,
    required this.title,
    required this.content,
  });

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(content),
      ),
    );
  }
}
