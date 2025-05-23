import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Forum screen uses when creting a new post.
class NewPostPopup extends StatefulWidget {
  const NewPostPopup({super.key});

  @override
  State<NewPostPopup> createState() => _NewPostPopupState();
}

class _NewPostPopupState extends State<NewPostPopup> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitPost() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.fillBothFields)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null)
        throw Exception(AppLocalizations.of(context)!.userOffline);

      await FirebaseFirestore.instance.collection('forum').add({
        'title': title,
        'content': content,
        'userId': user.uid,
        'date': Timestamp.now(),
        'like': 0,
        'likedBy': <String>[],
      });

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occured: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.newForumPost),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.title),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.content),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitPost,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(AppLocalizations.of(context)!.create),
        ),
      ],
    );
  }
}
