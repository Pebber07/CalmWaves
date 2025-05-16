import "package:calmwaves_app/palette.dart";
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import "package:calmwaves_app/widgets/gradient_button.dart";
import "package:calmwaves_app/widgets/login_field.dart";
import "package:flutter/material.dart";

class AddArticle extends StatefulWidget {
  final String articleTitle;
  final String articleImage;
  final String articleText;
  final TextEditingController articleTitleController;
  final TextEditingController articleExcerptController;
  final TextEditingController articleOptionalImageController;
  final TextEditingController articleOptionalVideoController;
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
    required this.articleOptionalVideoController,
  });

  @override
  State<AddArticle> createState() => _AddArticleState();
}

class _AddArticleState extends State<AddArticle> {
  bool _isUploadingImage = false;
  bool _isUploadingVideo = false;

  Future<void> _pickAndUploadImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isUploadingImage = true);

    final file = File(pickedFile.path);
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref =
        FirebaseStorage.instance.ref().child('article_images/$fileName.jpg');
    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();

    widget.articleOptionalImageController.text = downloadUrl;
    setState(() => _isUploadingImage = false);
  }

  Future<void> _pickAndUploadVideo() async {
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isUploadingVideo = true);

    final file = File(pickedFile.path);
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref =
        FirebaseStorage.instance.ref().child('article_videos/$fileName.mp4');
    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();

    widget.articleOptionalVideoController.text = downloadUrl;
    setState(() => _isUploadingVideo = false);
  }

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
          CustomTextField(
              hintText: "Add the articles title",
              controller: widget.articleTitleController,
              buttonLabelText: "Title",
              hideText: false),
          CustomTextField(
              hintText: "Add the articles excerpt",
              controller: widget.articleExcerptController,
              buttonLabelText: "Excerpt",
              hideText: false),
          TextField(
            controller: widget.articleTextController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Write your article content",
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 1.0),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isUploadingImage ? null : _pickAndUploadImage,
            icon: const Icon(Icons.image),
            label: _isUploadingImage
                ? const CircularProgressIndicator()
                : const Text("Choose a picture"),
          ),
          ElevatedButton.icon(
            onPressed: _isUploadingVideo ? null : _pickAndUploadVideo,
            icon: const Icon(Icons.video_library),
            label: _isUploadingVideo
                ? const CircularProgressIndicator()
                : const Text("Choose a video"),
          ),
          GradientButton(
              onPressed: widget.pressPostArticle,
              text: "Post article",
              buttonMargin: 20),
        ],
      ),
    );
  }
}
