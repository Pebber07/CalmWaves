import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";

class ArticleDetailScreen extends StatefulWidget {
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
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  String? _downloadUrl;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (widget.imageUrl.startsWith('gs://')) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(widget.imageUrl);
        final url = await ref.getDownloadURL();
        setState(() {
          _downloadUrl = url;
        });
      } catch (e) {
        print('Hiba a letöltési URL lekérésekor: $e');
      }
    } else {
      setState(() {
        _downloadUrl = widget.imageUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_downloadUrl != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.network(
                    _downloadUrl!, // works well if I set the storage rules well --> Auth, Sign In
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 50,
                      );
                    },
                  ),
                ),
              // else if (widget.imageUrl.isNotEmpty)
              //   const Padding(
              //     padding: EdgeInsets.all(16.0),
              //     child: CircularProgressIndicator(),
              //   ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.content,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ));
  }
}
