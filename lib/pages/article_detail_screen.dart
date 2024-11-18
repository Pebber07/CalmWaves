import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";

class ArticleDetailScreen extends StatelessWidget {
  final String title;
  final String content;
  final String imageUrl;
  const ArticleDetailScreen({
    super.key,
    required this.title,
    required this.content,
    required this.imageUrl,
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
      body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (imageUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        content,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                )
              );
            }
          }
