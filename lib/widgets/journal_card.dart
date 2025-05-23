import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Card that appers on journal screen.
class JournalCard extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final String docId;
  final Function onEdit;

  const JournalCard({
    super.key,
    required this.title,
    required this.content,
    required this.date,
    required this.docId,
    required this.onEdit,
  });

  Future<void> _deleteJournalEntry(BuildContext context) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.sureDelete),
        content: Text(AppLocalizations.of(context)!.journalDeleteDefinitively),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('journal')
            .doc(docId)
            .delete();
      } catch (e) {
        print("Error during deletion: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.lightBlue,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        trailing: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.delete),
          onPressed: () {
            _deleteJournalEntry(context);
          },
        ),
        onTap: () {
          onEdit();
        },
      ),
    );
  }
}
