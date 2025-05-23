import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import "package:calmwaves_app/widgets/gradient_button.dart";
import "package:calmwaves_app/widgets/custom_text_field.dart";
import "package:flutter/material.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Widget, that teh users use to create new article posts.
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
        color: Colors.blue[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              AppLocalizations.of(context)!.addOwnArticle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          CustomTextField(
              hintText: AppLocalizations.of(context)!.articleTitle,
              controller: widget.articleTitleController,
              buttonLabelText: AppLocalizations.of(context)!.title,
              hideText: false),
          const SizedBox(
            height: 15,
          ),
          CustomTextField(
              hintText: AppLocalizations.of(context)!.articleExcerpt,
              controller: widget.articleExcerptController,
              buttonLabelText: AppLocalizations.of(context)!.excerpt,
              hideText: false),
          const SizedBox(
            height: 15,
          ),
          TextField(
            controller: widget.articleTextController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.writeArticleContent,
              hintStyle: const TextStyle(
                color: Colors.white,
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 1.0),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: _isUploadingImage ? null : _pickAndUploadImage,
              icon: const Icon(Icons.image),
              label: _isUploadingImage
                  ? const CircularProgressIndicator()
                  : Text(AppLocalizations.of(context)!.chooseAPicture),
            ),
          ),
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, foregroundColor: Colors.white),
              onPressed: _isUploadingVideo ? null : _pickAndUploadVideo,
              icon: const Icon(Icons.video_library),
              label: _isUploadingVideo
                  ? const CircularProgressIndicator()
                  : Text(AppLocalizations.of(context)!.chooseAVideo),
            ),
          ),
          GradientButton(
              onPressed: widget.pressPostArticle,
              text: AppLocalizations.of(context)!.postArticle,
              buttonMargin: 20),
        ],
      ),
    );
  }
}
