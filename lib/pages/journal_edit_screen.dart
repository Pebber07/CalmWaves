import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// The users can create the journal entrys here.
class JournalEditScreen extends StatefulWidget {
  final String? docId;
  final String? initialTitle;
  final String? initialContent;
  const JournalEditScreen(
      {super.key, this.docId, this.initialTitle, this.initialContent});

  @override
  State<JournalEditScreen> createState() => _AddJournalEntryScreenState();
}

class _AddJournalEntryScreenState extends State<JournalEditScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _saveJournalEntry(String userId) async {
    final data = {
      'userid': userId,
      'title': _titleController.text,
      'content': _contentController.text,
      'lastModified': FieldValue.serverTimestamp(),
    };

    if (widget.docId != null) {
      await _firestore.collection('journal').doc(widget.docId).update(data);
    } else {
      await _firestore.collection('journal').add(data);
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _contentController.text = widget.initialContent ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createJournal),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "${AppLocalizations.of(context)!.title}:",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: "${AppLocalizations.of(context)!.content}:",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final user = _auth.currentUser;
                if (user != null) {
                  await _saveJournalEntry(user.uid);
                  Navigator.pop(context);
                }
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }
}
