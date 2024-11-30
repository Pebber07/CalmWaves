import "package:calmwaves_app/palette.dart";
import "package:calmwaves_app/widgets/gradient_button.dart";
import "package:calmwaves_app/widgets/login_field.dart";
import "package:flutter/material.dart";

class AddArticle extends StatelessWidget {
  final String articleTitle;
  final String articleImage;
  final String articleText;
  final TextEditingController articleTitleController;
  final TextEditingController articleExcerptController;
  final TextEditingController articleOptionalImageController;
  final TextEditingController articleTextController;
  final VoidCallback pressPostArticle;
  const AddArticle({
    super.key,
    required this.articleTitle,
    required this.articleImage,
    required this.articleText,
    required this.articleTitleController,
    required this.articleExcerptController,
    required this.articleOptionalImageController,
    required this.articleTextController,
    required this.pressPostArticle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Pallete.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Add your own article",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          // TextField with Label (title)
          LoginField(
              hintText: "Add the articles title",
              controller: articleTitleController,
              buttonLabelText: "Title",
              hideText: false),
          // TextField with Label (excerpt)
          LoginField(
              hintText: "Add the articles excerpt",
              controller: articleExcerptController,
              buttonLabelText: "Excerpt",
              hideText: false),
          // TextField with with label (Optional picture - hintext you can skip adding a picture)
          LoginField(
              hintText: "Add the articles picture",
              controller: articleOptionalImageController,
              buttonLabelText: "Optional image",
              hideText: false),
          // large Text
          const TextField(
            maxLines: 5,
            decoration: InputDecoration(
              hintText:
                  "Describe your message that you want to share with people.",
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 1.0),
              ),
            ),
          ),
          GradientButton(
              onPressed: pressPostArticle,
              text: "Post article",
              buttonMargin: 20),
        ],
      ),
    );
  }
}
