import "package:calmwaves_app/pages/article_accept_screen.dart";
import "package:calmwaves_app/widgets/accept_article_card.dart";
import "package:calmwaves_app/widgets/custom_app_bar.dart";
import "package:calmwaves_app/widgets/custom_drawer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Notifications Screen is only accessible for admins, they can accept - deny the users articles.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final CollectionReference articlesCollection =
      FirebaseFirestore.instance.collection("articles");

  Future<List<QueryDocumentSnapshot>> _getPendingArticles() async {
    final adminStatus = await _isAdmin();
    if (!adminStatus) {
      return [];
    }

    final querySnapshot = await articlesCollection.get();

    final pendingArticles = querySnapshot.docs.where((article) {
      final data = article.data() as Map<String, dynamic>?;

      final status = data?['status'];

      return status != null && status == 'pending';
    }).toList();

    return pendingArticles;
  }

  Future<bool> _isAdmin() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;

    final userDoc =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();
    return userDoc.data()?["userinfo"]["role"] == "admin";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _getPendingArticles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(AppLocalizations.of(context)!.noWaitingArticles));
          }

          final pendingArticles = snapshot.data!;
          return ListView.builder(
            itemCount: pendingArticles.length,
            itemBuilder: (context, index) {
              final article = pendingArticles[index];
              final data = article.data() as Map<String, dynamic>;
              final title =
                  data['title'] ?? AppLocalizations.of(context)!.noTitle;
              final excerpt =
                  data['excerpt'] ?? AppLocalizations.of(context)!.noExcerpt;
              final content =
                  data['content'] ?? AppLocalizations.of(context)!.noContent;

              return AcceptArticleCard(
                title: title,
                articleText: excerpt,
                onAccept: () async {
                  await article.reference.update({'status': 'approved'});
                  setState(() {});
                },
                onReject: () async {
                  await article.reference.update({'status': 'rejected'});
                  setState(() {});
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleAcceptScreen(
                        title: title,
                        content: content,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
