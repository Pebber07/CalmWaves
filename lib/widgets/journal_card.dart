import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";

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
        title: const Text("Biztosan törlöd?"),
        content: const Text("A naplóbejegyzés véglegesen törlődik."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Mégse"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Törlés"),
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
        print("Törlési hiba: $e");
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
          ),
        ),
        subtitle: Text(content, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: IconButton(
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
