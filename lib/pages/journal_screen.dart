import "package:calmwaves_app/pages/journal_edit_screen.dart";
import "package:calmwaves_app/widgets/custom_app_bar.dart";
import "package:calmwaves_app/widgets/custom_drawer.dart";
import "package:calmwaves_app/widgets/journal_card.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

// Felhasználó, cím, időpont, tartalom.
class _JournalScreenState extends State<JournalScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> _getJournalEntries(String userId) {
    return _firestore
        .collection('journal')
        .where('userid', isEqualTo: userId)
        .orderBy('lastModified', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Center(
          child: Text("Be kell jelentkezni a napló megtekintéséhez."));
    }

    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: StreamBuilder<QuerySnapshot>(
          stream: _getJournalEntries(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                  child: Text("Hiba történt az adatok betöltése közben."));
            }
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Center(child: Text("Nincsenek naplóbejegyzések."));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final docId = docs[index].id;

                return JournalCard(
                  title: data['title'] ?? 'Nincs cím',
                  content: data['content'] ?? 'Nincs tartalom',
                  date: data['lastModified'] != null
                      ? (data['lastModified'] as Timestamp).toDate().toString()
                      : 'Nincs dátum',
                  docId: docId,
                  onEdit: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JournalEditScreen(
                          docId: docId,
                          initialTitle: data['title'] ?? '',
                          initialContent: data['content'] ?? '',
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const JournalEditScreen(),
            ),
          );
        },
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
